<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="config.Conexion"%>
<%@page import="modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Usuario u = (Usuario) session.getAttribute("usuarioLogueado");
    if (u == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Connection cn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Flota y GPS Simulado - Cruz del Norte S.A.C.</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<nav class="navbar navbar-dark shadow-sm mb-4" style="background-color: #0b3967;">
    <div class="container">
        <a class="navbar-brand d-flex align-items-center gap-2 fw-bold" href="panel.jsp">
            <img src="logo-cruz-del-norte.png" alt="Cruz del Norte S.A.C." height="32" class="rounded bg-white p-1">
            <span>Cruz del Norte · Flota y GPS</span>
        </a>
        <a href="panel.jsp" class="btn btn-sm btn-outline-light">← Volver al Panel</a>
    </div>
</nav>

<div class="container pb-5">
    <div class="mb-4">
        <h4 class="fw-bold mb-1">Monitoreo de Flota y GPS Simulado (PIG-OPS)</h4>
        <p class="text-muted small mb-0">Simulación de coordenadas y velocidad con alerta automática sobre 90 km/h.</p>
    </div>

    <div class="card border-0 shadow-sm mb-4">
        <div class="card-body">
            <form class="row g-3 align-items-end" action="GpsServlet" method="post">
                <div class="col-md-3">
                    <label class="form-label fw-semibold small">Unidad / Bus</label>
                    <select name="idBus" class="form-select" required>
                        <option value="1">B4K-901 (Volvo B430R)</option>
                        <option value="2">C7M-318 (Scania K410)</option>
                        <option value="3">A2P-654 (Mercedes-Benz O500)</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label fw-semibold small">Latitud</label>
                    <input type="text" name="latitud" class="form-control" value="-9.074500" required>
                </div>
                <div class="col-md-2">
                    <label class="form-label fw-semibold small">Longitud</label>
                    <input type="text" name="longitud" class="form-control" value="-78.593600" required>
                </div>
                <div class="col-md-2">
                    <label class="form-label fw-semibold small">Velocidad (km/h)</label>
                    <input type="number" step="0.1" name="velocidad" class="form-control" value="75.0" required>
                </div>
                <div class="col-md-3">
                    <button type="submit" class="btn btn-primary w-100 fw-semibold">Registrar Señal GPS</button>
                </div>
            </form>
        </div>
    </div>

    <div class="card border-0 shadow-sm">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Placa</th>
                            <th>Modelo</th>
                            <th>Estado Bus</th>
                            <th>Latitud</th>
                            <th>Longitud</th>
                            <th>Velocidad</th>
                            <th>Alerta</th>
                            <th>Último Registro</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        try {
                            cn = Conexion.getConnection();
                            String sql = "SELECT b.placa, b.modelo, b.estado, g.latitud, g.longitud, g.velocidad_kmh, g.alerta, g.fecha_registro "
                                       + "FROM telemetria_gps g INNER JOIN buses b ON g.id_bus = b.id_bus "
                                       + "ORDER BY g.id_gps DESC LIMIT 15";
                            ps = cn.prepareStatement(sql);
                            rs = ps.executeQuery();

                            while (rs.next()) {
                                String alerta = rs.getString("alerta");
                                boolean esAlerta = !"NORMAL".equals(alerta);
                    %>
                        <tr>
                            <td class="fw-bold"><%= rs.getString("placa") %></td>
                            <td><%= rs.getString("modelo") %></td>
                            <td><span class="badge bg-light text-dark border"><%= rs.getString("estado") %></span></td>
                            <td><%= rs.getBigDecimal("latitud") %></td>
                            <td><%= rs.getBigDecimal("longitud") %></td>
                            <td><%= rs.getBigDecimal("velocidad_kmh") %> km/h</td>
                            <td>
                                <span class="badge <%= esAlerta ? "bg-danger" : "bg-success" %>"><%= alerta %></span>
                            </td>
                            <td class="small text-muted"><%= rs.getTimestamp("fecha_registro") %></td>
                        </tr>
                    <%
                            }
                        } catch (Exception e) {
                    %>
                        <tr><td colspan="8" class="text-danger">Error al cargar GPS: <%= e.getMessage() %></td></tr>
                    <%
                        } finally {
                            try { if (rs != null) rs.close(); } catch (Exception ex) {}
                            try { if (ps != null) ps.close(); } catch (Exception ex) {}
                            try { if (cn != null) cn.close(); } catch (Exception ex) {}
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
</body>
</html>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="config.Conexion"%>
<%@page import="modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    private String badgeEstadoUnidad(String estado) {
        String raw = estado != null ? estado.trim() : "";
        String val = raw.toUpperCase();
        String textoSinGuion = raw.replace("_", " ");

        if ("DISPONIBLE".equals(val) || "OPERATIVO".equals(val)) {
            return "<span class='badge rounded-pill bg-success px-3 py-2'>" + textoSinGuion + "</span>";
        } else if ("MANTENIMIENTO".equals(val) || "EN RUTA".equals(val) || "EN_RUTA".equals(val)) {
            return "<span class='badge rounded-pill bg-warning text-dark px-3 py-2'>" + textoSinGuion + "</span>";
        } else {
            String texto = textoSinGuion.isEmpty() ? "INACTIVO" : textoSinGuion;
            return "<span class='badge rounded-pill bg-danger px-3 py-2'>" + texto + "</span>";
        }
    }
%>
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
    <title>Control de Unidades - Cruz del Norte S.A.C.</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<nav class="navbar navbar-dark shadow-sm mb-4" style="background-color: #0b3967;">
    <div class="container">
        <a class="navbar-brand d-flex align-items-center gap-2 fw-bold" href="panel.jsp">
            <img src="logo-cruz-del-norte.png" alt="Cruz del Norte S.A.C." height="32" class="rounded bg-white p-1">
            <span>Cruz del Norte · Unidades</span>
        </a>
        <a href="panel.jsp" class="btn btn-sm btn-outline-light">← Volver al Panel</a>
    </div>
</nav>

<div class="container pb-5">
    <div class="mb-4">
        <h4 class="fw-bold mb-1">Registro y Control de Unidades / Buses (PIG-OPS)</h4>
        <p class="text-muted small mb-0">Semáforo de estado operativo: verde disponible/operativo, amarillo en ruta/mantenimiento y rojo inactivo.</p>
    </div>

    <!-- Formulario Registrar Unidad -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-white fw-bold">Nueva Unidad</div>
        <div class="card-body">
            <form class="row g-3 align-items-end" action="BusServlet" method="post">
                <div class="col-md-2">
                    <label class="form-label fw-semibold small">Placa</label>
                    <input type="text" name="placa" class="form-control" maxlength="15" placeholder="Ej: D5T-812" required>
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-semibold small">Modelo / Chasis</label>
                    <input type="text" name="modelo" class="form-control" placeholder="Ej: Volvo B430R" required>
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-semibold small">Servicio</label>
                    <select name="servicio" class="form-select" required>
                        <option value="Ejecutivo">Ejecutivo</option>
                        <option value="VIP Cama">VIP Cama</option>
                        <option value="Económico">Económico</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label fw-semibold small">Capacidad</label>
                    <input type="number" name="capacidad" class="form-control" min="10" max="70" value="44" required>
                </div>
                <div class="col-md-2">
                    <label class="form-label fw-semibold small">Estado</label>
                    <select name="estado" class="form-select" required>
                        <option value="DISPONIBLE">DISPONIBLE</option>
                        <option value="OPERATIVO">OPERATIVO</option>
                        <option value="EN_RUTA">EN RUTA</option>
                        <option value="MANTENIMIENTO">MANTENIMIENTO</option>
                        <option value="INACTIVO">INACTIVO</option>
                    </select>
                </div>
                <div class="col-12">
                    <button type="submit" class="btn btn-primary fw-semibold">Registrar Unidad</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Formulario Editar Unidad -->
    <div class="card border-primary shadow-sm mb-4 d-none" id="cardEditarBus">
        <div class="card-header bg-primary text-white fw-bold d-flex justify-content-between align-items-center">
            <span>Editar Unidad Seleccionada</span>
            <button type="button" class="btn btn-sm btn-light" onclick="cerrarEditarBus()">Cancelar</button>
        </div>
        <div class="card-body">
            <form class="row g-3 align-items-end" action="EditarBusServlet" method="post">
                <input type="hidden" name="idBus" id="editIdBus">
                <div class="col-md-2">
                    <label class="form-label fw-semibold small">Placa</label>
                    <input type="text" name="placa" id="editPlaca" class="form-control" maxlength="15" required>
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-semibold small">Modelo / Chasis</label>
                    <input type="text" name="modelo" id="editModelo" class="form-control" required>
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-semibold small">Servicio</label>
                    <select name="servicio" id="editServicio" class="form-select" required>
                        <option value="Ejecutivo">Ejecutivo</option>
                        <option value="VIP Cama">VIP Cama</option>
                        <option value="Económico">Económico</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label fw-semibold small">Capacidad</label>
                    <input type="number" name="capacidad" id="editCapacidad" class="form-control" min="10" max="70" required>
                </div>
                <div class="col-md-2">
                    <label class="form-label fw-semibold small">Estado</label>
                    <select name="estado" id="editEstado" class="form-select" required>
                        <option value="DISPONIBLE">DISPONIBLE</option>
                        <option value="OPERATIVO">OPERATIVO</option>
                        <option value="EN_RUTA">EN RUTA</option>
                        <option value="MANTENIMIENTO">MANTENIMIENTO</option>
                        <option value="INACTIVO">INACTIVO</option>
                    </select>
                </div>
                <div class="col-12">
                    <button type="submit" class="btn btn-success fw-semibold">Guardar Cambios</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Tabla de Unidades -->
    <div class="card border-0 shadow-sm">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>ID</th>
                            <th>Placa</th>
                            <th>Modelo</th>
                            <th>Servicio</th>
                            <th>Capacidad</th>
                            <th>Estado</th>
                            <th>Acción</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        try {
                            cn = Conexion.getConnection();
                            String sql = "SELECT id_bus, placa, modelo, servicio, capacidad, estado FROM buses ORDER BY id_bus DESC";
                            ps = cn.prepareStatement(sql);
                            rs = ps.executeQuery();

                            while (rs.next()) {
                                int idB = rs.getInt("id_bus");
                                String pl = rs.getString("placa");
                                String mo = rs.getString("modelo");
                                String se = rs.getString("servicio");
                                int ca = rs.getInt("capacidad");
                                String est = rs.getString("estado");
                    %>
                        <tr>
                            <td><%= idB %></td>
                            <td class="fw-bold"><%= pl %></td>
                            <td><%= mo %></td>
                            <td><%= se %></td>
                            <td><span class="badge bg-light text-dark border"><%= ca %> asientos</span></td>
                            <td><%= badgeEstadoUnidad(est) %></td>
                            <td>
                                <button type="button" class="btn btn-sm btn-outline-primary"
                                        data-id="<%= idB %>"
                                        data-placa="<%= pl %>"
                                        data-modelo="<%= mo %>"
                                        data-servicio="<%= se %>"
                                        data-capacidad="<%= ca %>"
                                        data-estado="<%= est %>"
                                        onclick="cargarEditarBus(this)">
                                    Editar
                                </button>
                            </td>
                        </tr>
                    <%
                            }
                        } catch (Exception e) {
                    %>
                        <tr><td colspan="7" class="text-danger">Error al cargar unidades: <%= e.getMessage() %></td></tr>
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

<script>
    function cargarEditarBus(btn) {
        document.getElementById("editIdBus").value = btn.getAttribute("data-id");
        document.getElementById("editPlaca").value = btn.getAttribute("data-placa");
        document.getElementById("editModelo").value = btn.getAttribute("data-modelo");
        document.getElementById("editServicio").value = btn.getAttribute("data-servicio");
        document.getElementById("editCapacidad").value = btn.getAttribute("data-capacidad");
        document.getElementById("editEstado").value = btn.getAttribute("data-estado");

        var card = document.getElementById("cardEditarBus");
        card.classList.remove("d-none");
        card.scrollIntoView({ behavior: "smooth" });
    }

    function cerrarEditarBus() {
        document.getElementById("cardEditarBus").classList.add("d-none");
    }
</script>
</body>
</html>
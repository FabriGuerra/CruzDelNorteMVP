<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="config.Conexion"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Usuario u = (Usuario) session.getAttribute("usuarioLogueado");
    if (u == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    BigDecimal totalSubtotal = BigDecimal.ZERO;
    BigDecimal totalIgv = BigDecimal.ZERO;
    BigDecimal totalGeneral = BigDecimal.ZERO;
    int cantidadBoletos = 0;

    Connection cn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cierre Diario / Caja - Cruz del Norte S.A.C.</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<nav class="navbar navbar-dark shadow-sm mb-4" style="background-color: #0b3967;">
    <div class="container">
        <a class="navbar-brand d-flex align-items-center gap-2 fw-bold" href="panel.jsp">
            <img src="logo-cruz-del-norte.png" alt="Cruz del Norte S.A.C." height="32" class="rounded bg-white p-1">
            <span>Cruz del Norte · Cierre de Caja</span>
        </a>
        <a href="panel.jsp" class="btn btn-sm btn-outline-light">← Volver al Panel</a>
    </div>
</nav>

<div class="container pb-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h4 class="fw-bold mb-1">Cierre Diario / Caja (PIG-ERP)</h4>
            <p class="text-muted small mb-0">Consolidado automático de boletos emitidos y exportación a hoja de cálculo.</p>
        </div>
        <a href="ExportarCajaServlet" class="btn btn-success fw-semibold">Exportar a Excel (.csv)</a>
    </div>

    <%
        StringBuilder filasHtml = new StringBuilder();
        try {
            cn = Conexion.getConnection();
            String sql = "SELECT codigo_qr, nombre_pasajero, dni_pasajero, nro_asiento, subtotal, igv, total, estado "
                       + "FROM boletos ORDER BY id_boleto DESC";
            ps = cn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                BigDecimal sub = rs.getBigDecimal("subtotal");
                BigDecimal igv = rs.getBigDecimal("igv");
                BigDecimal tot = rs.getBigDecimal("total");
                String est = rs.getString("estado");

                if ("PAGADO".equals(est)) {
                    totalSubtotal = totalSubtotal.add(sub);
                    totalIgv = totalIgv.add(igv);
                    totalGeneral = totalGeneral.add(tot);
                    cantidadBoletos++;
                }

                String badgeEst = "PAGADO".equals(est) ? "bg-success" : "bg-secondary";
                filasHtml.append("<tr>")
                         .append("<td><span class='fw-semibold text-primary'>").append(rs.getString("codigo_qr")).append("</span></td>")
                         .append("<td>").append(rs.getString("nombre_pasajero")).append(" <small class='text-muted'>(").append(rs.getString("dni_pasajero")).append(")</small></td>")
                         .append("<td><span class='badge bg-light text-dark border'>#").append(rs.getInt("nro_asiento")).append("</span></td>")
                         .append("<td>S/ ").append(sub).append("</td>")
                         .append("<td>S/ ").append(igv).append("</td>")
                         .append("<td class='fw-bold'>S/ ").append(tot).append("</td>")
                         .append("<td><span class='badge ").append(badgeEst).append("'>").append(est).append("</span></td>")
                         .append("</tr>");
            }
        } catch (Exception e) {
            filasHtml.append("<tr><td colspan='7' class='text-danger'>Error al cargar caja: ").append(e.getMessage()).append("</td></tr>");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ex) {}
            try { if (ps != null) ps.close(); } catch (Exception ex) {}
            try { if (cn != null) cn.close(); } catch (Exception ex) {}
        }
    %>

    <div class="row g-3 mb-4">
        <div class="col-sm-6 col-lg-3">
            <div class="card border-0 shadow-sm">
                <div class="card-body">
                    <div class="text-muted small">Boletos Pagados</div>
                    <div class="fs-4 fw-bold mt-1"><%= cantidadBoletos %></div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-lg-3">
            <div class="card border-0 shadow-sm">
                <div class="card-body">
                    <div class="text-muted small">Subtotal</div>
                    <div class="fs-4 fw-bold mt-1">S/ <%= totalSubtotal %></div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-lg-3">
            <div class="card border-0 shadow-sm">
                <div class="card-body">
                    <div class="text-muted small">IGV (18%)</div>
                    <div class="fs-4 fw-bold mt-1">S/ <%= totalIgv %></div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-lg-3">
            <div class="card border-0 shadow-sm border-start border-4 border-primary">
                <div class="card-body">
                    <div class="text-muted small">Total Caja</div>
                    <div class="fs-4 fw-bold text-primary mt-1">S/ <%= totalGeneral %></div>
                </div>
            </div>
        </div>
    </div>

    <div class="card border-0 shadow-sm">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Código QR</th>
                            <th>Pasajero</th>
                            <th>Asiento</th>
                            <th>Subtotal</th>
                            <th>IGV 18%</th>
                            <th>Total</th>
                            <th>Estado</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%= filasHtml.toString() %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
</body>
</html>
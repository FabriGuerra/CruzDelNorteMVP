<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.math.BigDecimal"%>
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

    StringBuilder filasTabla = new StringBuilder();
    StringBuilder puntosJs = new StringBuilder();
    String errorSql = null;
    double primeraLat = -9.074500;
    double primeraLng = -78.593600;
    boolean tienePunto = false;

    try {
        cn = Conexion.getConnection();
        String sql = "SELECT b.placa, b.modelo, b.estado, g.latitud, g.longitud, g.velocidad_kmh, g.alerta, g.fecha_registro "
                   + "FROM telemetria_gps g INNER JOIN buses b ON g.id_bus = b.id_bus "
                   + "ORDER BY g.id_gps DESC LIMIT 15";
        ps = cn.prepareStatement(sql);
        rs = ps.executeQuery();

        while (rs.next()) {
            String placa = rs.getString("placa") != null ? rs.getString("placa") : "";
            String modelo = rs.getString("modelo") != null ? rs.getString("modelo") : "";
            String estado = rs.getString("estado") != null ? rs.getString("estado") : "";
            BigDecimal latBd = rs.getBigDecimal("latitud");
            BigDecimal lngBd = rs.getBigDecimal("longitud");
            BigDecimal velBd = rs.getBigDecimal("velocidad_kmh");
            String alerta = rs.getString("alerta") != null ? rs.getString("alerta") : "NORMAL";
            String fechaStr = rs.getTimestamp("fecha_registro") != null ? rs.getTimestamp("fecha_registro").toString() : "";

            boolean esAlerta = !"NORMAL".equalsIgnoreCase(alerta);

            filasTabla.append("<tr>");
            filasTabla.append("<td class=\"fw-bold\">").append(escapeHtml(placa)).append("</td>");
            filasTabla.append("<td>").append(escapeHtml(modelo)).append("</td>");
            filasTabla.append("<td><span class=\"badge bg-light text-dark border\">").append(escapeHtml(estado)).append("</span></td>");
            filasTabla.append("<td>").append(latBd != null ? latBd.toPlainString() : "").append("</td>");
            filasTabla.append("<td>").append(lngBd != null ? lngBd.toPlainString() : "").append("</td>");
            filasTabla.append("<td>").append(velBd != null ? velBd.toPlainString() : "0").append(" km/h</td>");
            filasTabla.append("<td><span class=\"badge ").append(esAlerta ? "bg-danger" : "bg-success").append("\">")
                      .append(escapeHtml(alerta)).append("</span></td>");
            filasTabla.append("<td class=\"small text-muted\">").append(escapeHtml(fechaStr)).append("</td>");
            filasTabla.append("</tr>");

            if (latBd != null && lngBd != null) {
                double latVal = latBd.doubleValue();
                double lngVal = lngBd.doubleValue();
                if (latVal != 0.0 || lngVal != 0.0) {
                    double velVal = velBd != null ? velBd.doubleValue() : 0.0;
                    if (!tienePunto) {
                        primeraLat = latVal;
                        primeraLng = lngVal;
                        tienePunto = true;
                    }
                    if (puntosJs.length() > 0) {
                        puntosJs.append(",");
                    }
                    puntosJs.append("{")
                            .append("placa:\"").append(escapeJs(placa)).append("\",")
                            .append("modelo:\"").append(escapeJs(modelo)).append("\",")
                            .append("estado:\"").append(escapeJs(estado)).append("\",")
                            .append("lat:").append(latVal).append(",")
                            .append("lng:").append(lngVal).append(",")
                            .append("velocidad:").append(velVal).append(",")
                            .append("alerta:\"").append(escapeJs(alerta)).append("\",")
                            .append("fecha:\"").append(escapeJs(fechaStr)).append("\"")
                            .append("}");
                }
            }
        }
    } catch (Exception e) {
        errorSql = e.getMessage();
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ex) {}
        try { if (ps != null) ps.close(); } catch (Exception ex) {}
        try { if (cn != null) cn.close(); } catch (Exception ex) {}
    }
%>
<%!
    private String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String escapeJs(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("'", "\\'")
                .replace("\n", " ")
                .replace("\r", " ");
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Flota y GPS Simulado - Cruz del Norte S.A.C.</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <style>
        #mapaFlota {
            height: 420px;
            width: 100%;
            border-radius: 0.5rem;
            z-index: 1;
        }
    </style>
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

    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-white d-flex flex-wrap justify-content-between align-items-center gap-2 py-3">
            <div>
                <span class="fw-bold">Mapa en Tiempo Simulado (OpenStreetMap)</span>
                <span class="badge bg-success ms-2">Normal</span>
                <span class="badge bg-danger ms-1">Alerta (&gt; 90 km/h o estado crítico)</span>
            </div>
            <button type="button" id="btnCentrarUltimo" class="btn btn-sm btn-outline-primary">
                Centrar en último registro
            </button>
        </div>
        <div class="card-body">
            <div id="mapaFlota"></div>
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
                        if (errorSql != null) {
                    %>
                        <tr><td colspan="8" class="text-danger">Error al cargar GPS: <%= escapeHtml(errorSql) %></td></tr>
                    <%
                        } else {
                            out.print(filasTabla.toString());
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
    (function () {
        const puntos = [<%= puntosJs.toString() %>];
        const coordPorDefecto = [<%= primeraLat %>, <%= primeraLng %>];
        const map = L.map("mapaFlota").setView(coordPorDefecto, 11);

        L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
            maxZoom: 19,
            attribution: "&copy; OpenStreetMap contributors"
        }).addTo(map);

        const bounds = [];

        puntos.forEach((p, idx) => {
            const esAlerta = (p.alerta && p.alerta.toUpperCase() !== "NORMAL") || p.velocidad > 90;
            const colorMarcador = esAlerta ? "#dc3545" : "#198754";

            const marker = L.circleMarker([p.lat, p.lng], {
                radius: idx === 0 ? 11 : 8,
                fillColor: colorMarcador,
                color: "#ffffff",
                weight: 2,
                opacity: 1,
                fillOpacity: 0.9
            }).addTo(map);

            const badgeClass = esAlerta ? "bg-danger" : "bg-success";
            marker.bindPopup(
                "<div style='min-width:180px'>" +
                "<strong>" + p.placa + "</strong> <span class='text-muted'>(" + p.modelo + ")</span><br>" +
                "<span class='badge " + badgeClass + " my-1'>" + p.alerta + " · " + p.velocidad + " km/h</span><br>" +
                "<small>Estado: " + p.estado + "</small><br>" +
                "<small class='text-muted'>Coord: " + p.lat.toFixed(6) + ", " + p.lng.toFixed(6) + "</small><br>" +
                "<small class='text-muted'>" + p.fecha + "</small>" +
                "</div>"
            );

            bounds.push([p.lat, p.lng]);
            if (idx === 0) {
                marker.openPopup();
            }
        });

        if (bounds.length > 1) {
            map.fitBounds(bounds, { padding: [35, 35] });
        }

        const btnCentrar = document.getElementById("btnCentrarUltimo");
        if (btnCentrar) {
            btnCentrar.addEventListener("click", function () {
                map.setView(coordPorDefecto, 13);
            });
        }
    })();
</script>
</body>
</html>
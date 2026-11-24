<%@page import="java.util.concurrent.TimeUnit"%>
<%@page import="java.sql.Date"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="config.Conexion"%>
<%@page import="modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    private long diasRestantes(Date fecha, long hoyMs) {
        if (fecha == null) {
            return -9999L;
        }
        long diffMs = fecha.getTime() - hoyMs;
        return (long) Math.ceil((double) diffMs / TimeUnit.DAYS.toMillis(1));
    }

    private String badgeFecha(Date fecha, long hoyMs) {
        long dias = diasRestantes(fecha, hoyMs);
        if (dias < 0) {
            return "<span class='badge rounded-pill bg-danger mt-1'>Vencido (" + dias + " d)</span>";
        } else if (dias <= 15) {
            return "<span class='badge rounded-pill bg-warning text-dark mt-1'>Por vencer (" + dias + " d)</span>";
        } else {
            return "<span class='badge rounded-pill bg-success mt-1'>Vigente (" + dias + " d)</span>";
        }
    }
%>
<%
    Usuario u = (Usuario) session.getAttribute("usuarioLogueado");
    if (u == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    long hoyMs = System.currentTimeMillis();
    Connection cn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Control Documental - Cruz del Norte S.A.C.</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<nav class="navbar navbar-dark shadow-sm mb-4" style="background-color: #0b3967;">
    <div class="container">
        <a class="navbar-brand d-flex align-items-center gap-2 fw-bold" href="panel.jsp">
            <img src="logo-cruz-del-norte.png" alt="Cruz del Norte S.A.C." height="32" class="rounded bg-white p-1">
            <span>Cruz del Norte · Documentos</span>
        </a>
        <a href="panel.jsp" class="btn btn-sm btn-outline-light">← Volver al Panel</a>
    </div>
</nav>

<div class="container pb-5">
    <div class="mb-4">
        <h4 class="fw-bold mb-1">Control Documental de Conductores (RF-06)</h4>
        <p class="text-muted small mb-0">Semáforo de vigencia para Licencia de Conducir, SOAT y Revisión Técnica (MTC / SUTRAN).</p>
    </div>

    <!-- Formulario Registrar Conductor / Documento -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-white fw-bold">Registrar Control Documental</div>
        <div class="card-body">
            <form class="row g-3" action="DocumentoConductorServlet" method="post">
                <div class="col-md-3">
                    <label class="form-label fw-semibold small">DNI Conductor</label>
                    <input type="text" name="dniConductor" class="form-control" maxlength="15" required>
                </div>
                <div class="col-md-5">
                    <label class="form-label fw-semibold small">Nombres y Apellidos</label>
                    <input type="text" name="nombreConductor" class="form-control" required>
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-semibold small">Unidad Asignada (Bus)</label>
                    <select name="idBus" class="form-select" required>
                        <option value="1">B4K-901 (Volvo B430R)</option>
                        <option value="2">C7M-318 (Scania K410)</option>
                        <option value="3">A2P-654 (Mercedes-Benz O500)</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-semibold small">N° Licencia MTC</label>
                    <input type="text" name="nroLicencia" class="form-control" required>
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-semibold small">Vencimiento Licencia</label>
                    <input type="date" name="venceLicencia" class="form-control" required>
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-semibold small">Vencimiento SOAT</label>
                    <input type="date" name="venceSoat" class="form-control" required>
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-semibold small">Vencimiento Rev. Técnica</label>
                    <input type="date" name="venceRevision" class="form-control" required>
                </div>
                <div class="col-12">
                    <button type="submit" class="btn btn-primary fw-semibold">Registrar Control Documental</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Formulario Editar Conductor / Documento -->
    <div class="card border-primary shadow-sm mb-4 d-none" id="cardEditarDoc">
        <div class="card-header bg-primary text-white fw-bold d-flex justify-content-between align-items-center">
            <span>Editar Datos y Vigencia de Conductor</span>
            <button type="button" class="btn btn-sm btn-light" onclick="cerrarEditarDoc()">Cancelar</button>
        </div>
        <div class="card-body">
            <form class="row g-3" action="EditarDocumentoServlet" method="post">
                <input type="hidden" name="idDoc" id="editIdDoc">
                <div class="col-md-3">
                    <label class="form-label fw-semibold small">DNI Conductor</label>
                    <input type="text" name="dniConductor" id="editDniDoc" class="form-control" maxlength="15" required>
                </div>
                <div class="col-md-5">
                    <label class="form-label fw-semibold small">Nombres y Apellidos</label>
                    <input type="text" name="nombreConductor" id="editNombreDoc" class="form-control" required>
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-semibold small">Unidad Asignada (Bus)</label>
                    <select name="idBus" id="editIdBusDoc" class="form-select" required>
                        <option value="1">B4K-901 (Volvo B430R)</option>
                        <option value="2">C7M-318 (Scania K410)</option>
                        <option value="3">A2P-654 (Mercedes-Benz O500)</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-semibold small">N° Licencia MTC</label>
                    <input type="text" name="nroLicencia" id="editLicenciaDoc" class="form-control" required>
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-semibold small">Vencimiento Licencia</label>
                    <input type="date" name="venceLicencia" id="editVenceLic" class="form-control" required>
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-semibold small">Vencimiento SOAT</label>
                    <input type="date" name="venceSoat" id="editVenceSoat" class="form-control" required>
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-semibold small">Vencimiento Rev. Técnica</label>
                    <input type="date" name="venceRevision" id="editVenceRev" class="form-control" required>
                </div>
                <div class="col-12">
                    <button type="submit" class="btn btn-success fw-semibold">Actualizar Registro</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Buscador, Filtro y Tabla -->
    <div class="card border-0 shadow-sm">
        <div class="card-body">
            <div class="row g-2 align-items-center mb-3">
                <div class="col-md-6">
                    <div class="input-group">
                        <span class="input-group-text bg-white">Buscar</span>
                        <input type="text" id="buscadorDoc" class="form-control" placeholder="Nombre, DNI, placa o licencia..." onkeyup="filtrarDocumentos()">
                    </div>
                </div>
                <div class="col-md-4">
                    <select id="filtroEstado" class="form-select" onchange="filtrarDocumentos()">
                        <option value="TODOS">Todos los estados</option>
                        <option value="VIGENTE">Verde · Vigente</option>
                        <option value="POR VENCER">Amarillo · Por vencer</option>
                        <option value="VENCIDO">Rojo · Vencido</option>
                    </select>
                </div>
                <div class="col-md-2 d-grid">
                    <button type="button" class="btn btn-outline-secondary" onclick="limpiarBusqueda()">Limpiar</button>
                </div>
            </div>

            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0" id="tablaDocumentos">
                    <thead class="table-light">
                        <tr>
                            <th>Conductor (DNI)</th>
                            <th>Bus</th>
                            <th>Licencia MTC</th>
                            <th>Vence SOAT</th>
                            <th>Vence Rev. Técnica</th>
                            <th>Estado General</th>
                            <th>Acción</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        try {
                            cn = Conexion.getConnection();
                            String sql = "SELECT d.id_doc, d.dni_conductor, d.nombre_conductor, d.id_bus, b.placa, d.nro_licencia, "
                                       + "d.vence_licencia, d.vence_soat, d.vence_revision_tecnica "
                                       + "FROM documentos_conductores d INNER JOIN buses b ON d.id_bus = b.id_bus "
                                       + "ORDER BY d.id_doc DESC";
                            ps = cn.prepareStatement(sql);
                            rs = ps.executeQuery();

                            while (rs.next()) {
                                int idDoc = rs.getInt("id_doc");
                                String dni = rs.getString("dni_conductor");
                                String nombre = rs.getString("nombre_conductor");
                                int idBus = rs.getInt("id_bus");
                                String placa = rs.getString("placa");
                                String licencia = rs.getString("nro_licencia");
                                Date fLic = rs.getDate("vence_licencia");
                                Date fSoat = rs.getDate("vence_soat");
                                Date fRev = rs.getDate("vence_revision_tecnica");

                                long dLic = diasRestantes(fLic, hoyMs);
                                long dSoat = diasRestantes(fSoat, hoyMs);
                                long dRev = diasRestantes(fRev, hoyMs);

                                long minDias = Math.min(dLic, Math.min(dSoat, dRev));
                                String estadoBase;
                                String estadoLabel;
                                String badgeClass;

                                if (minDias < 0) {
                                    estadoBase = "VENCIDO";
                                    estadoLabel = "VENCIDO (" + minDias + " días)";
                                    badgeClass = "bg-danger";
                                } else if (minDias <= 15) {
                                    estadoBase = "POR VENCER";
                                    estadoLabel = "POR VENCER (" + minDias + " días)";
                                    badgeClass = "bg-warning text-dark";
                                } else {
                                    estadoBase = "VIGENTE";
                                    estadoLabel = "VIGENTE (" + minDias + " días)";
                                    badgeClass = "bg-success";
                                }
                    %>
                        <tr data-estado="<%= estadoBase %>">
                            <td>
                                <div class="fw-bold"><%= nombre %></div>
                                <small class="text-muted">DNI: <%= dni %></small>
                            </td>
                            <td><span class="badge bg-light text-dark border"><%= placa %></span></td>
                            <td>
                                <div class="fw-semibold"><%= licencia %></div>
                                <small class="text-muted d-block"><%= fLic %></small>
                                <%= badgeFecha(fLic, hoyMs) %>
                            </td>
                            <td>
                                <div><%= fSoat %></div>
                                <%= badgeFecha(fSoat, hoyMs) %>
                            </td>
                            <td>
                                <div><%= fRev %></div>
                                <%= badgeFecha(fRev, hoyMs) %>
                            </td>
                            <td><span class="badge rounded-pill <%= badgeClass %> px-3 py-2"><%= estadoLabel %></span></td>
                            <td>
                                <button type="button" class="btn btn-sm btn-outline-primary"
                                        data-id="<%= idDoc %>"
                                        data-dni="<%= dni %>"
                                        data-nombre="<%= nombre %>"
                                        data-idbus="<%= idBus %>"
                                        data-licencia="<%= licencia %>"
                                        data-vlic="<%= fLic %>"
                                        data-vsoat="<%= fSoat %>"
                                        data-vrev="<%= fRev %>"
                                        onclick="cargarEditarDoc(this)">
                                    Editar
                                </button>
                            </td>
                        </tr>
                    <%
                            }
                        } catch (Exception e) {
                    %>
                        <tr><td colspan="7" class="text-danger">Error al cargar documentos: <%= e.getMessage() %></td></tr>
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
    function cargarEditarDoc(btn) {
        document.getElementById("editIdDoc").value = btn.getAttribute("data-id");
        document.getElementById("editDniDoc").value = btn.getAttribute("data-dni");
        document.getElementById("editNombreDoc").value = btn.getAttribute("data-nombre");
        document.getElementById("editIdBusDoc").value = btn.getAttribute("data-idbus");
        document.getElementById("editLicenciaDoc").value = btn.getAttribute("data-licencia");
        document.getElementById("editVenceLic").value = btn.getAttribute("data-vlic");
        document.getElementById("editVenceSoat").value = btn.getAttribute("data-vsoat");
        document.getElementById("editVenceRev").value = btn.getAttribute("data-vrev");

        var card = document.getElementById("cardEditarDoc");
        card.classList.remove("d-none");
        card.scrollIntoView({ behavior: "smooth" });
    }

    function cerrarEditarDoc() {
        document.getElementById("cardEditarDoc").classList.add("d-none");
    }

    function filtrarDocumentos() {
        var texto = document.getElementById("buscadorDoc").value.toLowerCase().trim();
        var estadoSel = document.getElementById("filtroEstado").value;
        var filas = document.querySelectorAll("#tablaDocumentos tbody tr");

        filas.forEach(function (fila) {
            var estadoFila = fila.getAttribute("data-estado");
            if (!estadoFila) {
                return;
            }
            var contenido = fila.innerText.toLowerCase();
            var coincideTexto = texto === "" || contenido.indexOf(texto) !== -1;
            var coincideEstado = estadoSel === "TODOS" || estadoFila === estadoSel;

            fila.style.display = (coincideTexto && coincideEstado) ? "" : "none";
        });
    }

    function limpiarBusqueda() {
        document.getElementById("buscadorDoc").value = "";
        document.getElementById("filtroEstado").value = "TODOS";
        filtrarDocumentos();
    }
</script>
</body>
</html>
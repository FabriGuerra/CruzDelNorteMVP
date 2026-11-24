<%@page import="modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Usuario u = (Usuario) session.getAttribute("usuarioLogueado");
    if (u == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String rol = (u.getRol() != null && !u.getRol().trim().isEmpty())
            ? u.getRol().trim().toUpperCase()
            : "USUARIO";

    String nombreUsuario = (u.getNombre() != null && !u.getNombre().trim().isEmpty())
            ? u.getNombre().trim()
            : "Usuario";

    String inicial = nombreUsuario.substring(0, 1).toUpperCase();

    boolean esAdmin = "ADMIN".equalsIgnoreCase(rol) || "ADMINISTRADOR".equalsIgnoreCase(rol);
    boolean esVentas = esAdmin || "VENTAS".equalsIgnoreCase(rol);
    boolean esConta = esAdmin || "CONTABILIDAD".equalsIgnoreCase(rol);
    boolean esOps = esAdmin || "OPERACIONES".equalsIgnoreCase(rol);

    String cargoMostrar;
    if (esAdmin) {
        cargoMostrar = "Administrador General";
    } else if ("VENTAS".equalsIgnoreCase(rol)) {
        cargoMostrar = "Agente Comercial";
    } else if ("CONTABILIDAD".equalsIgnoreCase(rol)) {
        cargoMostrar = "Analista Contable";
    } else if ("OPERACIONES".equalsIgnoreCase(rol)) {
        cargoMostrar = "Despachador Senior";
    } else {
        cargoMostrar = rol;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel Principal - Cruz del Norte S.A.C.</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f4f7fb; }
        .sidebar { min-height: 100vh; background-color: #0b3967; color: #fff; }
        .sidebar .nav-link { color: rgba(255,255,255,0.85); border-radius: 8px; padding: 10px 14px; margin-bottom: 6px; }
        .sidebar .nav-link:hover, .sidebar .nav-link.active { background-color: rgba(255,255,255,0.14); color: #fff; }
        .module-card { border: 0; border-radius: 12px; box-shadow: 0 2px 10px rgba(15, 23, 42, 0.05); }
        .user-trigger { cursor: pointer; border-radius: 10px; padding: 6px; transition: background-color 0.2s ease; }
        .user-trigger:hover { background-color: rgba(255, 255, 255, 0.10); }
        .user-avatar {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            background: linear-gradient(135deg, #f59e0b, #d97706);
            color: #0b3967;
            font-weight: 700;
            font-size: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            border: 2px solid rgba(255, 255, 255, 0.25);
        }
    </style>
</head>
<body>
<div class="container-fluid">
    <div class="row">
        <!-- Barra Lateral -->
        <aside class="col-md-3 col-lg-2 sidebar p-3 d-flex flex-column justify-content-between">
            <div>
                <div class="d-flex align-items-center gap-2 pb-3 mb-3 border-bottom border-light border-opacity-25">
                    <img src="logo-cruz-del-norte.png" alt="Cruz del Norte S.A.C." height="36" class="rounded bg-white p-1">
                    <div>
                        <div class="fw-bold small lh-sm">Cruz del Norte</div>
                        <div class="text-white-50" style="font-size: 11px;">Operations MVP</div>
                    </div>
                </div>

                <nav class="nav flex-column">
                    <a class="nav-link active" href="panel.jsp">Dashboard</a>

                    <% if (esVentas) { %>
                        <a class="nav-link" href="venta.jsp">Venta de Pasajes</a>
                    <% } %>

                    <% if (esConta) { %>
                        <a class="nav-link" href="caja.jsp">Cierre de Caja Diario</a>
                    <% } %>

                    <% if (esOps) { %>
                        <a class="nav-link" href="unidades.jsp">Control y registro de Unidades</a>
                        <a class="nav-link" href="flota.jsp">Rastreo GPS de Flota</a>
                        <a class="nav-link" href="documentos.jsp">Documentos Conductores</a>
                    <% } %>

                    <% if (esConta || esOps) { %>
                        <a class="nav-link" href="repuestos.jsp">Almacén y Repuestos</a>
                    <% } %>
                </nav>
            </div>

            <!-- Perfil inferior en barra lateral -->
            <div class="pt-3 border-top border-light border-opacity-25">
                <div class="d-flex align-items-center justify-content-between gap-2 mb-3 user-trigger"
                     data-bs-toggle="modal"
                     data-bs-target="#modalUsuario"
                     title="Ver datos de sesión">
                    <div class="d-flex align-items-center gap-2 min-w-0">
                        <div class="user-avatar"><%= inicial %></div>
                        <div class="min-w-0">
                            <div class="fw-semibold text-white text-truncate" style="font-size: 14px;"><%= nombreUsuario %></div>
                            <div class="text-white-50 text-truncate" style="font-size: 12px;"><%= cargoMostrar %></div>
                        </div>
                    </div>
                    <span class="text-white-50 small">&#9652;</span>
                </div>
                <a href="LogoutServlet" class="btn btn-sm btn-danger w-100 fw-semibold">Cerrar Sesión</a>
            </div>
        </aside>

        <!-- Contenido Principal -->
        <main class="col-md-9 col-lg-10 p-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3 class="fw-bold mb-0">Dashboard</h3>
                    <small class="text-muted">Cruz del Norte S.A.C.</small>
                </div>
                <span class="badge bg-primary bg-opacity-10 text-primary px-3 py-2">Rol activo: <%= rol %></span>
            </div>

            <% if (!esVentas && !esConta && !esOps) { %>
                <div class="alert alert-warning small">
                    El rol en sesión es <strong><%= rol %></strong>. Revisa el valor de <code>rol</code> en la tabla <code>usuarios</code> o en <code>UsuarioDAO.validar()</code>.
                </div>
            <% } %>

            <div class="row g-3">
                <% if (esVentas) { %>
                <div class="col-sm-6 col-xl-4">
                    <div class="card module-card h-100">
                        <div class="card-body">
                            <div class="text-muted small">Módulo Comercial (PIG-COM)</div>
                            <h5 class="fw-bold mt-1">Venta de Pasajes</h5>
                            <p class="text-muted small mb-3">Emisión con IGV 18%, código QR y bloqueo de asientos.</p>
                            <a href="venta.jsp" class="btn btn-sm btn-primary">Ir a Venta</a>
                        </div>
                    </div>
                </div>
                <% } %>

                <% if (esConta) { %>
                <div class="col-sm-6 col-xl-4">
                    <div class="card module-card h-100">
                        <div class="card-body">
                            <div class="text-muted small">Módulo Financiero (PIG-ERP)</div>
                            <h5 class="fw-bold mt-1">Cierre Diario / Caja</h5>
                            <p class="text-muted small mb-3">Consolidado automático de boletos pagados e IGV.</p>
                            <a href="caja.jsp" class="btn btn-sm btn-outline-primary">Ir a Caja</a>
                        </div>
                    </div>
                </div>
                <% } %>

                <% if (esOps) { %>
                <div class="col-sm-6 col-xl-4">
                    <div class="card module-card h-100">
                        <div class="card-body">
                            <div class="text-muted small">Módulo Operativo (PIG-OPS)</div>
                            <h5 class="fw-bold mt-1">Registro de Unidades</h5>
                            <p class="text-muted small mb-3">Alta y control de buses operativos o en mantenimiento.</p>
                            <a href="unidades.jsp" class="btn btn-sm btn-outline-primary">Ir a Unidades</a>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-xl-4">
                    <div class="card module-card h-100">
                        <div class="card-body">
                            <div class="text-muted small">Telemetría en Ruta (PIG-OPS)</div>
                            <h5 class="fw-bold mt-1">Flota y GPS Simulado</h5>
                            <p class="text-muted small mb-3">Registro de coordenadas y alertas sobre 90 km/h.</p>
                            <a href="flota.jsp" class="btn btn-sm btn-outline-primary">Ir a Flota</a>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-xl-4">
                    <div class="card module-card h-100">
                        <div class="card-body">
                            <div class="text-muted small">Cumplimiento MTC/SUTRAN (RF-06)</div>
                            <h5 class="fw-bold mt-1">Control Documental</h5>
                            <p class="text-muted small mb-3">Vigencia de licencia, SOAT y revisión técnica con búsqueda.</p>
                            <a href="documentos.jsp" class="btn btn-sm btn-outline-primary">Ir a Documentos</a>
                        </div>
                    </div>
                </div>
                <% } %>

                <% if (esConta || esOps) { %>
                <div class="col-sm-6 col-xl-4">
                    <div class="card module-card h-100">
                        <div class="card-body">
                            <div class="text-muted small">Almacén y Repuestos (PIG-ERP · RF-04)</div>
                            <h5 class="fw-bold mt-1">Stock de Repuestos</h5>
                            <p class="text-muted small mb-3">Control de inventario y alertas de reabastecimiento crítico.</p>
                            <a href="repuestos.jsp" class="btn btn-sm btn-outline-primary">Ir a Almacén</a>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
        </main>
    </div>
</div>

<!-- Ventana modal con datos del usuario -->
<div class="modal fade" id="modalUsuario" tabindex="-1" aria-labelledby="modalUsuarioLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content border-0 shadow">
            <div class="modal-header text-white" style="background-color: #0b3967;">
                <h6 class="modal-title fw-bold mb-0" id="modalUsuarioLabel">Datos de Sesión</h6>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body text-center p-4">
                <div class="user-avatar mx-auto mb-3" style="width: 56px; height: 56px; font-size: 22px;">
                    <%= inicial %>
                </div>
                <h6 class="fw-bold mb-1"><%= nombreUsuario %></h6>
                <div class="text-muted small mb-2"><%= cargoMostrar %></div>
                <span class="badge bg-warning text-dark mb-3">ROL: <%= rol %></span>

                <div class="bg-light rounded p-2 text-start small border">
                    <div class="d-flex justify-content-between py-1 border-bottom">
                        <span class="text-muted">Empresa:</span>
                        <span class="fw-semibold">Cruz del Norte S.A.C.</span>
                    </div>
                    <div class="d-flex justify-content-between pt-1">
                        <span class="text-muted">Estado:</span>
                        <span class="text-success fw-semibold">Sesión activa</span>
                    </div>
                </div>
            </div>
            <div class="modal-footer bg-light justify-content-between py-2">
                <button type="button" class="btn btn-sm btn-secondary" data-bs-dismiss="modal">Cerrar</button>
                <a href="LogoutServlet" class="btn btn-sm btn-danger fw-semibold">Cerrar Sesión</a>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
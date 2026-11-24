<%@page import="java.util.List"%>
<%@page import="dao.RepuestoDAO"%>
<%@page import="modelo.Repuesto"%>
<%@page import="modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Usuario u = (Usuario) session.getAttribute("usuarioLogueado");
    if (u == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String buscar = request.getParameter("buscar");
    RepuestoDAO dao = new RepuestoDAO();
    List<Repuesto> lista = dao.listar(buscar);

    int alertasCriticas = 0;
    for (Repuesto item : lista) {
        if (item.getStockActual() <= item.getStockMinimo()) {
            alertasCriticas++;
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Almacén y Repuestos - Cruz del Norte S.A.C.</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<nav class="navbar navbar-dark shadow-sm mb-4" style="background-color: #0b3967;">
    <div class="container">
        <a class="navbar-brand d-flex align-items-center gap-2 fw-bold" href="panel.jsp">
            <img src="logo-cruz-del-norte.png" alt="Cruz del Norte S.A.C." height="32" class="rounded bg-white p-1">
            <span>Cruz del Norte · Almacén y Repuestos</span>
        </a>
        <a href="panel.jsp" class="btn btn-sm btn-outline-light">← Volver al Panel</a>
    </div>
</nav>

<div class="container pb-5">
    <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-2 mb-4">
        <div>
            <h4 class="fw-bold mb-1">Control de Almacén y Repuestos (PIG-ERP · RF-04)</h4>
            <p class="text-muted small mb-0">Stock de repuestos para mantenimiento con alertas de reabastecimiento crítico.</p>
        </div>
        <span class="badge <%= alertasCriticas > 0 ? "bg-danger" : "bg-success" %> px-3 py-2">
            Alertas críticas: <%= alertasCriticas %>
        </span>
    </div>

    <% if (alertasCriticas > 0) { %>
        <div class="alert alert-warning border-0 shadow-sm small mb-4" role="alert">
            <strong>Atención:</strong> Hay <strong><%= alertasCriticas %></strong> repuesto(s) en o por debajo del stock mínimo requerido para mantenimiento.
        </div>
    <% } %>

    <!-- Registrar Repuesto -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-white fw-bold">Registrar Repuesto</div>
        <div class="card-body">
            <form class="row g-3 align-items-end" action="RepuestoServlet" method="post">
                <div class="col-md-2">
                    <label class="form-label fw-semibold small">Código</label>
                    <input type="text" name="codigo" class="form-control" maxlength="25" placeholder="Ej: REP-005" required>
                </div>
                <div class="col-md-3">
                    <label class="form-label fw-semibold small">Repuesto</label>
                    <input type="text" name="nombre" class="form-control" placeholder="Ej: Filtro de aire" required>
                </div>
                <div class="col-md-2">
                    <label class="form-label fw-semibold small">Categoría</label>
                    <select name="categoria" class="form-select" required>
                        <option value="Motor">Motor</option>
                        <option value="Frenos">Frenos</option>
                        <option value="Transmisión">Transmisión</option>
                        <option value="Iluminación">Iluminación</option>
                        <option value="Suspensión">Suspensión</option>
                    </select>
                </div>
                <div class="col-md-1">
                    <label class="form-label fw-semibold small">Stock</label>
                    <input type="number" name="stockActual" class="form-control" min="0" value="10" required>
                </div>
                <div class="col-md-2">
                    <label class="form-label fw-semibold small">Stock Mín.</label>
                    <input type="number" name="stockMinimo" class="form-control" min="1" value="4" required>
                </div>
                <div class="col-md-2">
                    <label class="form-label fw-semibold small">Precio (S/)</label>
                    <input type="number" step="0.01" min="0" name="precioUnitario" class="form-control" value="50.00" required>
                </div>
                <div class="col-12">
                    <button type="submit" class="btn btn-primary fw-semibold">Guardar Repuesto</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Buscador y Tabla -->
    <div class="card border-0 shadow-sm">
        <div class="card-body">
            <form class="row g-2 mb-3" method="get" action="repuestos.jsp">
                <div class="col-sm-8 col-md-6">
                    <input type="text" name="buscar" class="form-control"
                           value="<%= buscar != null ? buscar : "" %>"
                           placeholder="Buscar por código, nombre o categoría...">
                </div>
                <div class="col-auto">
                    <button type="submit" class="btn btn-outline-primary">Buscar</button>
                </div>
                <% if (buscar != null && !buscar.trim().isEmpty()) { %>
                <div class="col-auto">
                    <a href="repuestos.jsp" class="btn btn-outline-secondary">Limpiar</a>
                </div>
                <% } %>
            </form>

            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Código</th>
                            <th>Repuesto</th>
                            <th>Categoría</th>
                            <th>Stock Actual</th>
                            <th>Mínimo</th>
                            <th>Precio Unit.</th>
                            <th>Estado</th>
                            <th>Movimiento</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        if (lista.isEmpty()) {
                    %>
                        <tr><td colspan="8" class="text-center text-muted py-4">No hay repuestos registrados.</td></tr>
                    <%
                        } else {
                            for (Repuesto r : lista) {
                                int actual = r.getStockActual();
                                int minimo = r.getStockMinimo();
                                String badgeClass;
                                String estadoTexto;

                                if (actual <= minimo) {
                                    badgeClass = "bg-danger";
                                    estadoTexto = "CRÍTICO";
                                } else if (actual <= minimo + 2) {
                                    badgeClass = "bg-warning text-dark";
                                    estadoTexto = "POR REPONER";
                                } else {
                                    badgeClass = "bg-success";
                                    estadoTexto = "ÓPTIMO";
                                }
                    %>
                        <tr>
                            <td class="fw-bold"><%= r.getCodigo() %></td>
                            <td><%= r.getNombre() %></td>
                            <td><%= r.getCategoria() %></td>
                            <td class="fw-bold"><%= actual %></td>
                            <td><%= minimo %></td>
                            <td>S/ <%= r.getPrecioUnitario() %></td>
                            <td><span class="badge rounded-pill <%= badgeClass %> px-3 py-2"><%= estadoTexto %></span></td>
                            <td>
                                <div class="d-flex gap-1">
                                    <form action="RepuestoServlet" method="post" class="d-inline">
                                        <input type="hidden" name="accion" value="ajustar">
                                        <input type="hidden" name="idRepuesto" value="<%= r.getIdRepuesto() %>">
                                        <input type="hidden" name="delta" value="1">
                                        <button type="submit" class="btn btn-sm btn-outline-success" title="Ingresar +1">+1</button>
                                    </form>
                                    <form action="RepuestoServlet" method="post" class="d-inline">
                                        <input type="hidden" name="accion" value="ajustar">
                                        <input type="hidden" name="idRepuesto" value="<%= r.getIdRepuesto() %>">
                                        <input type="hidden" name="delta" value="-1">
                                        <button type="submit" class="btn btn-sm btn-outline-danger" title="Descontar -1 por mantenimiento">-1</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    <%
                            }
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
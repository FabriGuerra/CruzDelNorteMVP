<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.List"%>
<%@page import="config.Conexion"%>
<%@page import="dao.BoletoDAO"%>
<%@page import="modelo.Boleto"%>
<%@page import="modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Usuario u = (Usuario) session.getAttribute("usuarioLogueado");
    if (u == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    BoletoDAO boletoDAO = new BoletoDAO();
    List<String[]> salidas = boletoDAO.listarSalidas();
    Boleto boletoEmitido = (Boleto) request.getAttribute("boletoEmitido");
    String errorVenta = (String) request.getAttribute("errorVenta");

    // Obtener asientos ocupados (PAGADO) por id_salida para actualizar el croquis al cambiar de salida
    StringBuilder mapaOcupados = new StringBuilder("{");
    Connection cnOcup = null;
    PreparedStatement psOcup = null;
    ResultSet rsOcup = null;
    try {
        cnOcup = Conexion.getConnection();
        String sqlOcup = "SELECT id_salida, nro_asiento FROM boletos WHERE estado = 'PAGADO'";
        psOcup = cnOcup.prepareStatement(sqlOcup);
        rsOcup = psOcup.executeQuery();

        boolean primero = true;
        int salidaActual = -1;
        while (rsOcup.next()) {
            int idSal = rsOcup.getInt("id_salida");
            int nroAs = rsOcup.getInt("nro_asiento");
            if (idSal != salidaActual) {
                if (salidaActual != -1) {
                    mapaOcupados.append("]");
                }
                if (!primero) {
                    mapaOcupados.append(", ");
                }
                mapaOcupados.append("\"").append(idSal).append("\": [").append(nroAs);
                salidaActual = idSal;
                primero = false;
            } else {
                mapaOcupados.append(", ").append(nroAs);
            }
        }
        if (salidaActual != -1) {
            mapaOcupados.append("]");
        }
    } catch (Exception e) {
        System.out.println("Error al cargar asientos ocupados: " + e.getMessage());
    } finally {
        try { if (rsOcup != null) rsOcup.close(); } catch (Exception ex) {}
        try { if (psOcup != null) psOcup.close(); } catch (Exception ex) {}
        try { if (cnOcup != null) cnOcup.close(); } catch (Exception ex) {}
    }
    mapaOcupados.append("}");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Venta de Pasajes - Cruz del Norte S.A.C.</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<nav class="navbar navbar-dark shadow-sm mb-4" style="background-color: #0b3967;">
    <div class="container">
        <a class="navbar-brand d-flex align-items-center gap-2 fw-bold" href="panel.jsp">
            <img src="logo-cruz-del-norte.png" alt="Cruz del Norte S.A.C." height="32" class="rounded bg-white p-1">
            <span>Cruz del Norte · Venta de Pasajes</span>
        </a>
        <a href="panel.jsp" class="btn btn-sm btn-outline-light">← Volver al Panel</a>
    </div>
</nav>

<div class="container pb-5">
    <div class="row justify-content-center">
        <div class="col-lg-8">
            <div class="card border-0 shadow-sm">
                <div class="card-body p-4">
                    <h4 class="fw-bold mb-1">Venta de Pasajes (PIG-COM)</h4>
                    <p class="text-muted small mb-4">Emisión con cálculo automático de IGV (18%), código QR y selección visual de asiento.</p>

                    <form action="VentaServlet" method="post" onsubmit="return validarAsientoElegido();">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Ruta y Salida</label>
                            <select name="idSalida" id="idSalida" class="form-select" onchange="alCambiarSalida()" required>
                                <% for (String[] s : salidas) { %>
                                    <option value="<%= s[0] %>" data-precio="<%= s[2] %>"><%= s[1] %> | <%= s[4] %></option>
                                <% } %>
                            </select>
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-md-5">
                                <label class="form-label fw-semibold">DNI / CE del Pasajero</label>
                                <input type="text" name="dni" class="form-control" maxlength="15" placeholder="Ej: 45891230" required>
                            </div>
                            <div class="col-md-7">
                                <label class="form-label fw-semibold">Nombres y Apellidos</label>
                                <input type="text" name="nombre" class="form-control" placeholder="Ej: Carlos Mendoza" required>
                            </div>
                        </div>

                        <!-- Croquis Visual de Asientos -->
                        <div class="mb-3">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <label class="form-label fw-semibold mb-0">Selección Visual de Asiento</label>
                                <div class="d-flex gap-2 small">
                                    <span class="badge bg-success">Libre</span>
                                    <span class="badge bg-primary">Elegido</span>
                                    <span class="badge bg-danger">Ocupado</span>
                                </div>
                            </div>

                            <div class="p-3 bg-light border rounded">
                                <div class="text-center text-muted small fw-semibold mb-2">FRENTE DEL BUS / CABINA</div>
                                <div id="croquisAsientos" class="d-flex flex-column gap-2 align-items-center"></div>
                            </div>
                        </div>

                        <div class="row g-3 mb-4">
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Número de Asiento</label>
                                <input type="number" name="nroAsiento" id="nroAsiento" class="form-control bg-light fw-bold" min="1" max="60" placeholder="Haz clic en un asiento libre" readonly required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Precio Total (S/ · IGV 18%)</label>
                                <input type="text" name="precio" id="precio" class="form-control bg-light fw-bold" readonly>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary w-100 fw-semibold">Emitir Boleto</button>
                    </form>

                    <% if (errorVenta != null) { %>
                        <div class="alert alert-danger mt-4 mb-0" role="alert">
                            <%= errorVenta %>
                        </div>
                    <% } %>

                    <% if (boletoEmitido != null) { %>
                        <div class="alert alert-success mt-4 mb-0" role="alert">
                            <div class="fw-bold mb-1">¡Boleto emitido correctamente!</div>
                            <div>Código / QR: <span class="badge bg-dark"><%= boletoEmitido.getCodigoQr() %></span></div>
                            <div>Pasajero: <strong><%= boletoEmitido.getNombrePasajero() %></strong> (DNI: <%= boletoEmitido.getDniPasajero() %>)</div>
                            <div>Asiento N°: <strong>#<%= boletoEmitido.getNroAsiento() %></strong></div>
                            <div class="mt-1 small">
                                Subtotal: <strong>S/ <%= boletoEmitido.getSubtotal() %></strong> ·
                                IGV (18%): <strong>S/ <%= boletoEmitido.getIgv() %></strong> ·
                                Total: <strong>S/ <%= boletoEmitido.getTotal() %></strong>
                            </div>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    var ocupadosPorSalida = <%= mapaOcupados.toString() %>;
    var totalAsientos = 44;

    function actualizarPrecio() {
        var select = document.getElementById("idSalida");
        if (!select || select.selectedIndex < 0) return;
        var option = select.options[select.selectedIndex];
        var precio = option.getAttribute("data-precio");
        document.getElementById("precio").value = precio || "";
    }

    function renderizarCroquis() {
        var select = document.getElementById("idSalida");
        var idSalidaActual = select ? select.value : "";
        var ocupados = ocupadosPorSalida[idSalidaActual] || [];

        var contenedor = document.getElementById("croquisAsientos");
        var inputAsiento = document.getElementById("nroAsiento");
        contenedor.innerHTML = "";
        inputAsiento.value = "";

        for (var i = 1; i <= totalAsientos; i += 4) {
            var fila = document.createElement("div");
            fila.className = "d-flex gap-2 justify-content-center align-items-center";

            for (var offset = 0; offset < 4; offset++) {
                var num = i + offset;
                if (num > totalAsientos) break;

                if (offset === 2) {
                    var pasillo = document.createElement("span");
                    pasillo.style.width = "24px";
                    pasillo.className = "d-inline-block text-center text-muted small";
                    pasillo.innerText = "|";
                    fila.appendChild(pasillo);
                }

                var btn = document.createElement("button");
                btn.type = "button";
                btn.style.width = "44px";
                btn.innerText = num;
                btn.setAttribute("data-asiento", num);

                if (ocupados.indexOf(num) !== -1) {
                    btn.className = "btn btn-sm btn-danger";
                    btn.disabled = true;
                } else {
                    btn.className = "btn btn-sm btn-outline-success asiento-libre";
                    btn.onclick = function () {
                        var todos = document.querySelectorAll(".asiento-libre");
                        todos.forEach(function (b) {
                            b.classList.remove("btn-primary");
                            b.classList.add("btn-outline-success");
                        });
                        this.classList.remove("btn-outline-success");
                        this.classList.add("btn-primary");
                        inputAsiento.value = this.getAttribute("data-asiento");
                    };
                }

                fila.appendChild(btn);
            }

            contenedor.appendChild(fila);
        }
    }

    function alCambiarSalida() {
        actualizarPrecio();
        renderizarCroquis();
    }

    function validarAsientoElegido() {
        var asiento = document.getElementById("nroAsiento").value;
        if (!asiento) {
            alert("Selecciona un asiento disponible en el croquis antes de emitir el boleto.");
            return false;
        }
        return true;
    }

    window.onload = function () {
        actualizarPrecio();
        renderizarCroquis();
    };
</script>
</body>
</html>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String errorLogin = (String) request.getAttribute("error");
    if (errorLogin == null) {
        errorLogin = (String) request.getAttribute("errorLogin");
    }
    if (errorLogin == null) {
        errorLogin = request.getParameter("error");
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar Sesión - Cruz del Norte S.A.C.</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            min-height: 100vh;
            background: linear-gradient(135deg, #072646 0%, #0b3967 55%, #124d87 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
        }
        .login-card {
            max-width: 880px;
            width: 100%;
            border: 0;
            border-radius: 18px;
            overflow: hidden;
            box-shadow: 0 20px 50px rgba(3, 15, 30, 0.35);
        }
        .brand-panel {
            background: linear-gradient(160deg, #092f56 0%, #0d457d 100%);
            color: #ffffff;
        }
        .form-control {
            padding: 11px 14px;
            border-radius: 10px;
            border-color: #dbe3ee;
        }
        .form-control:focus {
            border-color: #0b3967;
            box-shadow: 0 0 0 0.2rem rgba(11, 57, 103, 0.15);
        }
        .btn-login {
            background-color: #0b3967;
            border-color: #0b3967;
            padding: 11px 16px;
            border-radius: 10px;
            font-weight: 600;
        }
        .btn-login:hover, .btn-login:focus {
            background-color: #082b4e;
            border-color: #082b4e;
        }
    </style>
</head>
<body>
<div class="card login-card bg-white">
    <div class="row g-0">
        <!-- Panel Izquierdo -->
        <div class="col-lg-5 brand-panel p-4 p-md-5 d-flex flex-column justify-content-between">
            <div class="d-flex align-items-center gap-3">
                <img src="logo-cruz-del-norte.png" alt="Cruz del Norte S.A.C." height="50" class="rounded-3 bg-white p-1 shadow-sm">
                <div>
                    <h5 class="fw-bold mb-0">Cruz del Norte</h5>
                    <small class="text-white-50">S.A.C.</small>
                </div>
            </div>

            <div class="pt-4 mt-4 border-top border-light border-opacity-10 small text-white-50">
                Acceso interno al sistema
            </div>
        </div>

        <!-- Panel Derecho: Formulario -->
        <div class="col-lg-7 p-4 p-md-5 d-flex flex-column justify-content-center">
            <div class="mb-4">
                <h4 class="fw-bold text-dark mb-1">Iniciar Sesión</h4>
                <p class="text-muted small mb-0">Ingresa tu usuario y contraseña para continuar.</p>
            </div>

            <% if (errorLogin != null && !errorLogin.trim().isEmpty()) { %>
                <div class="alert alert-danger py-2 px-3 small rounded-3" role="alert">
                    <%= errorLogin %>
                </div>
            <% } %>

            <form action="LoginServlet" method="post">
                <div class="mb-3">
                    <label for="usuario" class="form-label fw-semibold small text-dark">Usuario</label>
                    <input type="text" id="usuario" name="usuario" class="form-control"
                           placeholder="Ingresa tu usuario" autocomplete="username" required autofocus>
                </div>

                <div class="mb-4">
                    <label for="clave" class="form-label fw-semibold small text-dark">Contraseña</label>
                    <input type="password" id="clave" name="clave" class="form-control"
                           placeholder="Ingresa tu contraseña" autocomplete="current-password" required>
                </div>

                <button type="submit" class="btn btn-primary btn-login w-100">Ingresar</button>
            </form>

            <div class="mt-4 pt-3 border-top text-center small text-muted">
                Empresa de Transportes Cruz del Norte S.A.C.
            </div>
        </div>
    </div>
</div>
</body>
</html>
package controlador;

import dao.UsuarioDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import modelo.Usuario;

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String user = request.getParameter("usuario");
        String pass = request.getParameter("clave");

        UsuarioDAO dao = new UsuarioDAO();
        Usuario u = dao.validar(user, pass);

        if (u != null) {
            HttpSession sesion = request.getSession();
            sesion.setAttribute("usuarioLogueado", u);
            response.sendRedirect("panel.jsp");
        } else {
            request.setAttribute("error", "Usuario o clave incorrectos.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}
package controlador;

import dao.RepuestoDAO;
import java.io.IOException;
import java.math.BigDecimal;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import modelo.Repuesto;
import modelo.Usuario;

@WebServlet(name = "RepuestoServlet", urlPatterns = {"/RepuestoServlet"})
public class RepuestoServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession sesion = request.getSession(false);
        Usuario u = sesion != null ? (Usuario) sesion.getAttribute("usuarioLogueado") : null;
        if (u == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String accion = request.getParameter("accion");
        RepuestoDAO dao = new RepuestoDAO();

        if ("ajustar".equals(accion)) {
            try {
                int idRepuesto = Integer.parseInt(request.getParameter("idRepuesto"));
                int delta = Integer.parseInt(request.getParameter("delta"));
                dao.ajustarStock(idRepuesto, delta);
            } catch (NumberFormatException e) {
                System.out.println("Error en ajuste de stock: " + e.getMessage());
            }
            response.sendRedirect("repuestos.jsp");
            return;
        }

        try {
            Repuesto r = new Repuesto();
            r.setCodigo(request.getParameter("codigo"));
            r.setNombre(request.getParameter("nombre"));
            r.setCategoria(request.getParameter("categoria"));
            r.setStockActual(Integer.parseInt(request.getParameter("stockActual")));
            r.setStockMinimo(Integer.parseInt(request.getParameter("stockMinimo")));

            String precioStr = request.getParameter("precioUnitario");
            BigDecimal precio = (precioStr != null && !precioStr.trim().isEmpty())
                    ? new BigDecimal(precioStr.trim())
                    : BigDecimal.ZERO;
            r.setPrecioUnitario(precio);

            dao.registrar(r);
        } catch (Exception e) {
            System.out.println("Error al procesar repuesto: " + e.getMessage());
        }

        response.sendRedirect("repuestos.jsp");
    }
}
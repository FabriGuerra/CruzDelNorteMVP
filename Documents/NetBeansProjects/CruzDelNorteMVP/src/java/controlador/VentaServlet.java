package controlador;

import dao.BoletoDAO;
import java.io.IOException;
import java.math.BigDecimal;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import modelo.Boleto;

@WebServlet(name = "VentaServlet", urlPatterns = {"/VentaServlet"})
public class VentaServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int idSalida = Integer.parseInt(request.getParameter("idSalida"));
            String dni = request.getParameter("dni").trim();
            String nombre = request.getParameter("nombre").trim();
            int nroAsiento = Integer.parseInt(request.getParameter("nroAsiento"));
            BigDecimal total = new BigDecimal(request.getParameter("precio"));

            BoletoDAO dao = new BoletoDAO();
            Boleto emitido = dao.registrarVenta(idSalida, dni, nombre, nroAsiento, total);

            if (emitido != null) {
                request.setAttribute("boletoEmitido", emitido);
            } else {
                request.setAttribute("errorVenta", "El asiento #" + nroAsiento + " ya está ocupado o hubo un error al registrar.");
            }
        } catch (Exception e) {
            request.setAttribute("errorVenta", "Verifica los datos ingresados en la venta.");
        }

        request.getRequestDispatcher("venta.jsp").forward(request, response);
    }
}
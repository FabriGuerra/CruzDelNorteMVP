package controlador;

import config.Conexion;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "EditarBusServlet", urlPatterns = {"/EditarBusServlet"})
public class EditarBusServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Connection cn = null;
        PreparedStatement ps = null;

        try {
            int idBus = Integer.parseInt(request.getParameter("idBus"));
            String placa = request.getParameter("placa").trim().toUpperCase();
            String modelo = request.getParameter("modelo").trim();
            String servicio = request.getParameter("servicio").trim();
            int capacidad = Integer.parseInt(request.getParameter("capacidad"));
            String estado = request.getParameter("estado").trim();

            String sql = "UPDATE buses SET placa = ?, modelo = ?, servicio = ?, capacidad = ?, estado = ? WHERE id_bus = ?";
            cn = Conexion.getConnection();
            ps = cn.prepareStatement(sql);
            ps.setString(1, placa);
            ps.setString(2, modelo);
            ps.setString(3, servicio);
            ps.setInt(4, capacidad);
            ps.setString(5, estado);
            ps.setInt(6, idBus);
            ps.executeUpdate();
        } catch (Exception e) {
            System.out.println("Error al editar unidad: " + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception ex) {}
            try { if (cn != null) cn.close(); } catch (Exception ex) {}
        }

        response.sendRedirect("unidades.jsp");
    }
}
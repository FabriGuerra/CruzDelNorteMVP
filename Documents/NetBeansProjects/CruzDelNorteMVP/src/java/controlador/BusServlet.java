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

@WebServlet(name = "BusServlet", urlPatterns = {"/BusServlet"})
public class BusServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Connection cn = null;
        PreparedStatement ps = null;

        try {
            String placa = request.getParameter("placa").trim().toUpperCase();
            String modelo = request.getParameter("modelo").trim();
            String servicio = request.getParameter("servicio").trim();
            int capacidad = Integer.parseInt(request.getParameter("capacidad"));
            String estado = request.getParameter("estado").trim();

            String sql = "INSERT INTO buses (placa, modelo, servicio, capacidad, estado) VALUES (?, ?, ?, ?, ?)";
            cn = Conexion.getConnection();
            ps = cn.prepareStatement(sql);
            ps.setString(1, placa);
            ps.setString(2, modelo);
            ps.setString(3, servicio);
            ps.setInt(4, capacidad);
            ps.setString(5, estado);
            ps.executeUpdate();
        } catch (Exception e) {
            System.out.println("Error al registrar unidad: " + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception ex) {}
            try { if (cn != null) cn.close(); } catch (Exception ex) {}
        }

        response.sendRedirect("unidades.jsp");
    }
}
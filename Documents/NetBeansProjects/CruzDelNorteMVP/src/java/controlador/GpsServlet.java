package controlador;

import config.Conexion;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "GpsServlet", urlPatterns = {"/GpsServlet"})
public class GpsServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int idBus = Integer.parseInt(request.getParameter("idBus"));
            BigDecimal lat = new BigDecimal(request.getParameter("latitud"));
            BigDecimal lon = new BigDecimal(request.getParameter("longitud"));
            BigDecimal vel = new BigDecimal(request.getParameter("velocidad"));
            String alerta = vel.compareTo(new BigDecimal("90")) > 0 ? "EXCESO DE VELOCIDAD" : "NORMAL";

            String sql = "INSERT INTO telemetria_gps (id_bus, latitud, longitud, velocidad_kmh, alerta) VALUES (?, ?, ?, ?, ?)";
            try (Connection cn = Conexion.getConnection();
                 PreparedStatement ps = cn.prepareStatement(sql)) {
                ps.setInt(1, idBus);
                ps.setBigDecimal(2, lat);
                ps.setBigDecimal(3, lon);
                ps.setBigDecimal(4, vel);
                ps.setString(5, alerta);
                ps.executeUpdate();
            }
        } catch (Exception e) {
            System.out.println("Error al actualizar GPS: " + e.getMessage());
        }

        response.sendRedirect("flota.jsp");
    }
}
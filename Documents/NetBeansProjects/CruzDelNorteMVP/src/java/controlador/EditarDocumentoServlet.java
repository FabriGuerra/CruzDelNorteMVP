package controlador;

import config.Conexion;
import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "EditarDocumentoServlet", urlPatterns = {"/EditarDocumentoServlet"})
public class EditarDocumentoServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Connection cn = null;
        PreparedStatement ps = null;

        try {
            int idDoc = Integer.parseInt(request.getParameter("idDoc"));
            String dni = request.getParameter("dniConductor").trim();
            String nombre = request.getParameter("nombreConductor").trim();
            int idBus = Integer.parseInt(request.getParameter("idBus"));
            String licencia = request.getParameter("nroLicencia").trim();
            Date venceLic = Date.valueOf(request.getParameter("venceLicencia"));
            Date venceSoat = Date.valueOf(request.getParameter("venceSoat"));
            Date venceRev = Date.valueOf(request.getParameter("venceRevision"));

            String sql = "UPDATE documentos_conductores SET dni_conductor = ?, nombre_conductor = ?, id_bus = ?, "
                       + "nro_licencia = ?, vence_licencia = ?, vence_soat = ?, vence_revision_tecnica = ? WHERE id_doc = ?";

            cn = Conexion.getConnection();
            ps = cn.prepareStatement(sql);
            ps.setString(1, dni);
            ps.setString(2, nombre);
            ps.setInt(3, idBus);
            ps.setString(4, licencia);
            ps.setDate(5, venceLic);
            ps.setDate(6, venceSoat);
            ps.setDate(7, venceRev);
            ps.setInt(8, idDoc);
            ps.executeUpdate();
        } catch (Exception e) {
            System.out.println("Error al editar documento de conductor: " + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception ex) {}
            try { if (cn != null) cn.close(); } catch (Exception ex) {}
        }

        response.sendRedirect("documentos.jsp");
    }
}
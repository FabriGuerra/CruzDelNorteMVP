package controlador;

import config.Conexion;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "ExportarCajaServlet", urlPatterns = {"/ExportarCajaServlet"})
public class ExportarCajaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/vnd.ms-excel; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"cierre_caja_cruz_del_norte.xls\"");

        PrintWriter out = response.getWriter();
        BigDecimal totalSubtotal = BigDecimal.ZERO;
        BigDecimal totalIgv = BigDecimal.ZERO;
        BigDecimal totalGeneral = BigDecimal.ZERO;
        int boletosPagados = 0;

        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        out.println("<html><head><meta charset='UTF-8'></head><body>");
        out.println("<table border='1' cellspacing='0' cellpadding='6' style='font-family: Arial, sans-serif; border-collapse: collapse;'>");

        // Encabezado del reporte
        out.println("<tr>");
        out.println("<td colspan='8' style='background-color: #0b3967; color: #ffffff; font-size: 15px; font-weight: bold; text-align: center;'>");
        out.println("CRUZ DEL NORTE S.A.C. - REPORTE DE CIERRE DIARIO DE CAJA (PIG-ERP)");
        out.println("</td>");
        out.println("</tr>");

        // Cabecera de columnas
        out.println("<tr style='background-color: #1e5a96; color: #ffffff; font-weight: bold; text-align: center;'>");
        out.println("<th>Código QR</th>");
        out.println("<th>Pasajero</th>");
        out.println("<th>DNI</th>");
        out.println("<th>Asiento</th>");
        out.println("<th>Subtotal (S/)</th>");
        out.println("<th>IGV 18% (S/)</th>");
        out.println("<th>Total (S/)</th>");
        out.println("<th>Estado</th>");
        out.println("</tr>");

        try {
            cn = Conexion.getConnection();
            String sql = "SELECT codigo_qr, nombre_pasajero, dni_pasajero, nro_asiento, subtotal, igv, total, estado "
                       + "FROM boletos ORDER BY id_boleto DESC";
            ps = cn.prepareStatement(sql);
            rs = ps.executeQuery();

            int fila = 0;
            while (rs.next()) {
                String qr = escaparHtml(rs.getString("codigo_qr"));
                String pasajero = escaparHtml(rs.getString("nombre_pasajero"));
                String dni = escaparHtml(rs.getString("dni_pasajero"));
                int asiento = rs.getInt("nro_asiento");
                BigDecimal sub = rs.getBigDecimal("subtotal");
                BigDecimal igv = rs.getBigDecimal("igv");
                BigDecimal tot = rs.getBigDecimal("total");
                String est = escaparHtml(rs.getString("estado"));

                if ("PAGADO".equals(est)) {
                    totalSubtotal = totalSubtotal.add(sub);
                    totalIgv = totalIgv.add(igv);
                    totalGeneral = totalGeneral.add(tot);
                    boletosPagados++;
                }

                String fondoFila = (fila % 2 == 0) ? "#ffffff" : "#f4f7fb";
                String colorEstado = "PAGADO".equals(est) ? "#198754" : "#6c757d";

                out.println("<tr style='background-color: " + fondoFila + ";'>");
                out.println("<td style='font-weight: bold;'>" + qr + "</td>");
                out.println("<td>" + pasajero + "</td>");
                out.println("<td style='text-align: center;'>" + dni + "</td>");
                out.println("<td style='text-align: center;'>#" + asiento + "</td>");
                out.println("<td style='text-align: right;'>S/ " + sub + "</td>");
                out.println("<td style='text-align: right;'>S/ " + igv + "</td>");
                out.println("<td style='text-align: right; font-weight: bold;'>S/ " + tot + "</td>");
                out.println("<td style='text-align: center; font-weight: bold; color: " + colorEstado + ";'>" + est + "</td>");
                out.println("</tr>");
                fila++;
            }

            // Fila de totales
            out.println("<tr style='background-color: #e9eef5; font-weight: bold;'>");
            out.println("<td colspan='4' style='text-align: right;'>TOTAL BOLETOS PAGADOS (" + boletosPagados + "):</td>");
            out.println("<td style='text-align: right;'>S/ " + totalSubtotal + "</td>");
            out.println("<td style='text-align: right;'>S/ " + totalIgv + "</td>");
            out.println("<td style='text-align: right; color: #0b3967;'>S/ " + totalGeneral + "</td>");
            out.println("<td></td>");
            out.println("</tr>");

        } catch (Exception e) {
            out.println("<tr><td colspan='8'>Error al generar reporte: " + escaparHtml(e.getMessage()) + "</td></tr>");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ex) {}
            try { if (ps != null) ps.close(); } catch (Exception ex) {}
            try { if (cn != null) cn.close(); } catch (Exception ex) {}
        }

        out.println("</table>");
        out.println("</body></html>");
        out.flush();
    }

    private String escaparHtml(String texto) {
        if (texto == null) {
            return "";
        }
        return texto.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;");
    }
}
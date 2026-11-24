package dao;

import config.Conexion;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import modelo.Boleto;

public class BoletoDAO {

    public List<String[]> listarSalidas() {
        List<String[]> lista = new ArrayList<>();
        String sql = "SELECT s.id_salida, s.origen, s.destino, s.fecha_salida, s.hora_salida, s.precio, b.placa, b.servicio, b.capacidad "
                   + "FROM rutas_salidas s INNER JOIN buses b ON s.id_bus = b.id_bus ORDER BY s.id_salida";
        try (Connection cn = Conexion.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(new String[]{
                    String.valueOf(rs.getInt("id_salida")),
                    rs.getString("origen") + " -> " + rs.getString("destino") + " (" + rs.getString("hora_salida") + ") - S/ " + rs.getBigDecimal("precio"),
                    rs.getBigDecimal("precio").toPlainString(),
                    String.valueOf(rs.getInt("capacidad")),
                    rs.getString("placa") + " / " + rs.getString("servicio")
                });
            }
        } catch (Exception e) {
            System.out.println("Error al listar salidas: " + e.getMessage());
        }
        return lista;
    }

    public boolean asientoOcupado(int idSalida, int nroAsiento) {
        String sql = "SELECT COUNT(*) FROM boletos WHERE id_salida = ? AND nro_asiento = ? AND estado = 'PAGADO'";
        try (Connection cn = Conexion.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idSalida);
            ps.setInt(2, nroAsiento);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            System.out.println("Error al verificar asiento: " + e.getMessage());
        }
        return true;
    }

    public Boleto registrarVenta(int idSalida, String dni, String nombre, int nroAsiento, BigDecimal total) {
        if (asientoOcupado(idSalida, nroAsiento)) {
            return null;
        }

        BigDecimal subtotal = total.divide(new BigDecimal("1.18"), 2, RoundingMode.HALF_UP);
        BigDecimal igv = total.subtract(subtotal).setScale(2, RoundingMode.HALF_UP);
        String codigoQr = "CDN-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        String sql = "INSERT INTO boletos (id_salida, dni_pasajero, nombre_pasajero, nro_asiento, codigo_qr, subtotal, igv, total, estado) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'PAGADO')";

        try (Connection cn = Conexion.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idSalida);
            ps.setString(2, dni);
            ps.setString(3, nombre);
            ps.setInt(4, nroAsiento);
            ps.setString(5, codigoQr);
            ps.setBigDecimal(6, subtotal);
            ps.setBigDecimal(7, igv);
            ps.setBigDecimal(8, total);

            int filas = ps.executeUpdate();
            if (filas > 0) {
                Boleto b = new Boleto();
                b.setIdSalida(idSalida);
                b.setDniPasajero(dni);
                b.setNombrePasajero(nombre);
                b.setNroAsiento(nroAsiento);
                b.setCodigoQr(codigoQr);
                b.setSubtotal(subtotal);
                b.setIgv(igv);
                b.setTotal(total);
                b.setEstado("PAGADO");
                return b;
            }
        } catch (Exception e) {
            System.out.println("Error al registrar boleto: " + e.getMessage());
        }
        return null;
    }
}
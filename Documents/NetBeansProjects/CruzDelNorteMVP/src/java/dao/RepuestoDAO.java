package dao;

import config.Conexion;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import modelo.Repuesto;

public class RepuestoDAO {

    public List<Repuesto> listar(String buscar) {
        List<Repuesto> lista = new ArrayList<>();
        Connection cn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            cn = Conexion.getConnection();
            boolean tieneFiltro = buscar != null && !buscar.trim().isEmpty();
            String sql = tieneFiltro
                    ? "SELECT id_repuesto, codigo, nombre, categoria, stock_actual, stock_minimo, precio_unitario FROM repuestos WHERE UPPER(codigo) LIKE ? OR UPPER(nombre) LIKE ? OR UPPER(categoria) LIKE ? ORDER BY id_repuesto DESC"
                    : "SELECT id_repuesto, codigo, nombre, categoria, stock_actual, stock_minimo, precio_unitario FROM repuestos ORDER BY id_repuesto DESC";

            ps = cn.prepareStatement(sql);
            if (tieneFiltro) {
                String patron = "%" + buscar.trim().toUpperCase() + "%";
                ps.setString(1, patron);
                ps.setString(2, patron);
                ps.setString(3, patron);
            }

            rs = ps.executeQuery();
            while (rs.next()) {
                Repuesto r = new Repuesto();
                r.setIdRepuesto(rs.getInt("id_repuesto"));
                r.setCodigo(rs.getString("codigo"));
                r.setNombre(rs.getString("nombre"));
                r.setCategoria(rs.getString("categoria"));
                r.setStockActual(rs.getInt("stock_actual"));
                r.setStockMinimo(rs.getInt("stock_minimo"));
                r.setPrecioUnitario(rs.getBigDecimal("precio_unitario"));
                lista.add(r);
            }
        } catch (Exception e) {
            System.out.println("Error al listar repuestos: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ex) {}
            try { if (ps != null) ps.close(); } catch (Exception ex) {}
            try { if (cn != null) cn.close(); } catch (Exception ex) {}
        }

        return lista;
    }

    public boolean registrar(Repuesto r) {
        Connection cn = null;
        PreparedStatement ps = null;
        try {
            cn = Conexion.getConnection();
            String sql = "INSERT INTO repuestos (codigo, nombre, categoria, stock_actual, stock_minimo, precio_unitario) VALUES (?, ?, ?, ?, ?, ?)";
            ps = cn.prepareStatement(sql);
            ps.setString(1, r.getCodigo().trim().toUpperCase());
            ps.setString(2, r.getNombre().trim());
            ps.setString(3, r.getCategoria().trim());
            ps.setInt(4, r.getStockActual());
            ps.setInt(5, r.getStockMinimo());
            ps.setBigDecimal(6, r.getPrecioUnitario() != null ? r.getPrecioUnitario() : BigDecimal.ZERO);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("Error al registrar repuesto: " + e.getMessage());
            return false;
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception ex) {}
            try { if (cn != null) cn.close(); } catch (Exception ex) {}
        }
    }

    public boolean ajustarStock(int idRepuesto, int delta) {
        Connection cn = null;
        PreparedStatement ps = null;
        try {
            cn = Conexion.getConnection();
            String sql = "UPDATE repuestos SET stock_actual = GREATEST(0, stock_actual + ?) WHERE id_repuesto = ?";
            ps = cn.prepareStatement(sql);
            ps.setInt(1, delta);
            ps.setInt(2, idRepuesto);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("Error al ajustar stock: " + e.getMessage());
            return false;
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception ex) {}
            try { if (cn != null) cn.close(); } catch (Exception ex) {}
        }
    }
}
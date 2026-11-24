package dao;

import config.Conexion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import modelo.Usuario;

public class UsuarioDAO {

    public Usuario validar(String usuario, String clave) {
        Usuario u = null;
        String sql = "SELECT id_usuario, nombre, usuario, rol FROM usuarios WHERE usuario = ? AND clave = ? AND activo = 1";

        try (Connection cn = Conexion.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, usuario);
            ps.setString(2, clave);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    u = new Usuario();
                    u.setIdUsuario(rs.getInt("id_usuario"));
                    u.setNombre(rs.getString("nombre"));
                    u.setUsuario(rs.getString("usuario"));
                    u.setRol(rs.getString("rol"));
                }
            }
        } catch (Exception e) {
            System.out.println("Error al validar usuario: " + e.getMessage());
        }
        return u;
    }
}
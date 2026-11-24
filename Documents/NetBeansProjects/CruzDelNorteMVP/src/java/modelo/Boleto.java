package modelo;

import java.math.BigDecimal;

public class Boleto {
    private int idBoleto;
    private int idSalida;
    private String dniPasajero;
    private String nombrePasajero;
    private int nroAsiento;
    private String codigoQr;
    private BigDecimal subtotal;
    private BigDecimal igv;
    private BigDecimal total;
    private String estado;

    public int getIdBoleto() { return idBoleto; }
    public void setIdBoleto(int idBoleto) { this.idBoleto = idBoleto; }

    public int getIdSalida() { return idSalida; }
    public void setIdSalida(int idSalida) { this.idSalida = idSalida; }

    public String getDniPasajero() { return dniPasajero; }
    public void setDniPasajero(String dniPasajero) { this.dniPasajero = dniPasajero; }

    public String getNombrePasajero() { return nombrePasajero; }
    public void setNombrePasajero(String nombrePasajero) { this.nombrePasajero = nombrePasajero; }

    public int getNroAsiento() { return nroAsiento; }
    public void setNroAsiento(int nroAsiento) { this.nroAsiento = nroAsiento; }

    public String getCodigoQr() { return codigoQr; }
    public void setCodigoQr(String codigoQr) { this.codigoQr = codigoQr; }

    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }

    public BigDecimal getIgv() { return igv; }
    public void setIgv(BigDecimal igv) { this.igv = igv; }

    public BigDecimal getTotal() { return total; }
    public void setTotal(BigDecimal total) { this.total = total; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
}
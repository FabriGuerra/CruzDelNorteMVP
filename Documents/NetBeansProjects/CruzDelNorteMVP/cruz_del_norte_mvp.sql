-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 24-11-2026 a las 07:58:32
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `cruz_del_norte_mvp`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `boletos`
--

CREATE TABLE `boletos` (
  `id_boleto` int(11) NOT NULL,
  `id_salida` int(11) NOT NULL,
  `dni_pasajero` varchar(20) NOT NULL,
  `nombre_pasajero` varchar(120) NOT NULL,
  `nro_asiento` int(11) NOT NULL,
  `codigo_qr` varchar(60) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `igv` decimal(10,2) NOT NULL,
  `total` decimal(10,2) NOT NULL,
  `fecha_venta` datetime DEFAULT current_timestamp(),
  `estado` enum('PAGADO','ANULADO') DEFAULT 'PAGADO'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `boletos`
--

INSERT INTO `boletos` (`id_boleto`, `id_salida`, `dni_pasajero`, `nombre_pasajero`, `nro_asiento`, `codigo_qr`, `subtotal`, `igv`, `total`, `fecha_venta`, `estado`) VALUES
(1, 1, '45454545', 'Carlos Mendoza', 12, 'CDN-F8CD6649', 55.08, 9.92, 65.00, '2026-11-23 23:55:41', 'PAGADO');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `buses`
--

CREATE TABLE `buses` (
  `id_bus` int(11) NOT NULL,
  `placa` varchar(20) NOT NULL,
  `modelo` varchar(80) NOT NULL,
  `servicio` varchar(50) NOT NULL,
  `capacidad` int(11) NOT NULL,
  `estado` enum('DISPONIBLE','EN_RUTA','MANTENIMIENTO') DEFAULT 'DISPONIBLE'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `buses`
--

INSERT INTO `buses` (`id_bus`, `placa`, `modelo`, `servicio`, `capacidad`, `estado`) VALUES
(1, 'B4K-901', 'Volvo B430R', 'Bus Cama', 42, 'EN_RUTA'),
(2, 'C7M-318', 'Scania K410', 'Primera Clase', 48, 'DISPONIBLE'),
(3, 'A2P-654', 'Mercedes-Benz O500', 'Economico', 52, 'DISPONIBLE');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `documentos_conductores`
--

CREATE TABLE `documentos_conductores` (
  `id_doc` int(11) NOT NULL,
  `dni_conductor` varchar(15) NOT NULL,
  `nombre_conductor` varchar(120) NOT NULL,
  `id_bus` int(11) NOT NULL,
  `nro_licencia` varchar(30) NOT NULL,
  `vence_licencia` date NOT NULL,
  `vence_soat` date NOT NULL,
  `vence_revision_tecnica` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `documentos_conductores`
--

INSERT INTO `documentos_conductores` (`id_doc`, `dni_conductor`, `nombre_conductor`, `id_bus`, `nro_licencia`, `vence_licencia`, `vence_soat`, `vence_revision_tecnica`) VALUES
(1, '41258963', 'Roberto Quispe Huamán', 1, 'Q41258963', '2027-01-08', '2026-12-04', '2026-11-24'),
(2, '45987120', 'Miguel Ángel Soto Paredes', 2, 'Q45987120', '2026-11-21', '2027-02-22', '2026-12-19'),
(3, '47852369', 'Jorge Luis Ramos Vega', 3, 'Q47852369', '2027-03-24', '2027-01-23', '2026-12-02');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `repuestos`
--

CREATE TABLE `repuestos` (
  `id_repuesto` int(11) NOT NULL,
  `codigo` varchar(25) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `categoria` varchar(50) NOT NULL,
  `stock_actual` int(11) NOT NULL DEFAULT 0,
  `stock_minimo` int(11) NOT NULL DEFAULT 5,
  `precio_unitario` decimal(10,2) NOT NULL DEFAULT 0.00,
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `repuestos`
--

INSERT INTO `repuestos` (`id_repuesto`, `codigo`, `nombre`, `categoria`, `stock_actual`, `stock_minimo`, `precio_unitario`, `actualizado_en`) VALUES
(1, 'REP-001', 'Pastillas de freno delanteras', 'Frenos', 18, 6, 145.00, '2026-11-24 06:14:38'),
(2, 'REP-002', 'Filtro de aceite motor Volvo', 'Motor', 4, 5, 88.50, '2026-11-24 06:14:38'),
(3, 'REP-003', 'Faja de alternador', 'Transmisión', 0, 3, 62.00, '2026-11-24 06:14:38'),
(4, 'REP-004', 'Lámpara halógena H4 / Faro', 'Iluminación', 12, 4, 35.00, '2026-11-24 06:14:38');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rutas_salidas`
--

CREATE TABLE `rutas_salidas` (
  `id_salida` int(11) NOT NULL,
  `id_bus` int(11) NOT NULL,
  `origen` varchar(80) NOT NULL,
  `destino` varchar(80) NOT NULL,
  `fecha_salida` date NOT NULL,
  `hora_salida` time NOT NULL,
  `precio` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `rutas_salidas`
--

INSERT INTO `rutas_salidas` (`id_salida`, `id_bus`, `origen`, `destino`, `fecha_salida`, `hora_salida`, `precio`) VALUES
(1, 1, 'Lima - Plaza Norte', 'Chimbote', '2026-11-23', '21:00:00', 65.00),
(2, 2, 'Lima - La Victoria', 'Trujillo', '2026-11-23', '22:00:00', 85.00),
(3, 3, 'Chimbote', 'Lima - Plaza Norte', '2026-11-23', '08:00:00', 55.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `telemetria_gps`
--

CREATE TABLE `telemetria_gps` (
  `id_gps` int(11) NOT NULL,
  `id_bus` int(11) NOT NULL,
  `latitud` decimal(10,6) NOT NULL,
  `longitud` decimal(10,6) NOT NULL,
  `velocidad_kmh` decimal(5,2) NOT NULL,
  `alerta` varchar(120) DEFAULT 'NORMAL',
  `fecha_registro` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `telemetria_gps`
--

INSERT INTO `telemetria_gps` (`id_gps`, `id_bus`, `latitud`, `longitud`, `velocidad_kmh`, `alerta`, `fecha_registro`) VALUES
(1, 1, -9.074500, -78.593600, 78.50, 'NORMAL', '2026-11-23 23:40:54'),
(2, 2, -11.993500, -77.062800, 0.00, 'EN TERMINAL', '2026-11-23 23:40:54'),
(3, 3, -9.085000, -78.578000, 62.00, 'NORMAL', '2026-11-23 23:40:54');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `usuario` varchar(50) NOT NULL,
  `clave` varchar(100) NOT NULL,
  `rol` enum('ADMIN','VENTAS','OPERACIONES','CONTABILIDAD') NOT NULL,
  `activo` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `nombre`, `usuario`, `clave`, `rol`, `activo`) VALUES
(1, 'Admin Cruz del Norte', 'admin', '1234', 'ADMIN', 1),
(2, 'Taquilla Plaza Norte', 'ventas', '1234', 'VENTAS', 1),
(3, 'Control Flota', 'operaciones', '1234', 'OPERACIONES', 1),
(4, 'Cierre Contable', 'contabilidad', '1234', 'CONTABILIDAD', 1);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `boletos`
--
ALTER TABLE `boletos`
  ADD PRIMARY KEY (`id_boleto`),
  ADD UNIQUE KEY `codigo_qr` (`codigo_qr`),
  ADD UNIQUE KEY `uq_asiento_salida` (`id_salida`,`nro_asiento`);

--
-- Indices de la tabla `buses`
--
ALTER TABLE `buses`
  ADD PRIMARY KEY (`id_bus`),
  ADD UNIQUE KEY `placa` (`placa`);

--
-- Indices de la tabla `documentos_conductores`
--
ALTER TABLE `documentos_conductores`
  ADD PRIMARY KEY (`id_doc`),
  ADD KEY `fk_doc_bus` (`id_bus`);

--
-- Indices de la tabla `repuestos`
--
ALTER TABLE `repuestos`
  ADD PRIMARY KEY (`id_repuesto`),
  ADD UNIQUE KEY `codigo` (`codigo`);

--
-- Indices de la tabla `rutas_salidas`
--
ALTER TABLE `rutas_salidas`
  ADD PRIMARY KEY (`id_salida`),
  ADD KEY `fk_salida_bus` (`id_bus`);

--
-- Indices de la tabla `telemetria_gps`
--
ALTER TABLE `telemetria_gps`
  ADD PRIMARY KEY (`id_gps`),
  ADD KEY `fk_gps_bus` (`id_bus`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `usuario` (`usuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `boletos`
--
ALTER TABLE `boletos`
  MODIFY `id_boleto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `buses`
--
ALTER TABLE `buses`
  MODIFY `id_bus` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `documentos_conductores`
--
ALTER TABLE `documentos_conductores`
  MODIFY `id_doc` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `repuestos`
--
ALTER TABLE `repuestos`
  MODIFY `id_repuesto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `rutas_salidas`
--
ALTER TABLE `rutas_salidas`
  MODIFY `id_salida` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `telemetria_gps`
--
ALTER TABLE `telemetria_gps`
  MODIFY `id_gps` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `boletos`
--
ALTER TABLE `boletos`
  ADD CONSTRAINT `fk_boleto_salida` FOREIGN KEY (`id_salida`) REFERENCES `rutas_salidas` (`id_salida`);

--
-- Filtros para la tabla `documentos_conductores`
--
ALTER TABLE `documentos_conductores`
  ADD CONSTRAINT `fk_doc_bus` FOREIGN KEY (`id_bus`) REFERENCES `buses` (`id_bus`);

--
-- Filtros para la tabla `rutas_salidas`
--
ALTER TABLE `rutas_salidas`
  ADD CONSTRAINT `fk_salida_bus` FOREIGN KEY (`id_bus`) REFERENCES `buses` (`id_bus`);

--
-- Filtros para la tabla `telemetria_gps`
--
ALTER TABLE `telemetria_gps`
  ADD CONSTRAINT `fk_gps_bus` FOREIGN KEY (`id_bus`) REFERENCES `buses` (`id_bus`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

# Registro de rotación de credenciales · Planta Maipo Sur

> **Rotación simulada** para el taller: la planta y el PLC son ficticios. En una planta real,
> cada fila corresponde a un cambio hecho en el equipo, con revisión de accesos.
> Ningún valor de clave se escribe aquí ni en ningún otro archivo del repositorio.

| Fecha | Credencial | Motivo | Acción | Dónde vive ahora | Responsable |
|---|---|---|---|---|---|
| 06-10-2026 | Clave de la pasarela OT (`turno-noche`) | Quedó escrita en `config.yaml`, commit `dc95c45`, en un repositorio público | Se considera comprometida: se cambió en la pasarela (simulado), se retiró del código y se revisaron accesos de los últimos 7 días (simulado) | Secreto `PLC_PASSWORD` del repositorio | Guardián del pipeline |
| 06-10-2026 | Cuenta de mantenimiento del PLC-01 (`admin` / clave de fábrica) | Credencial de fábrica publicada en el manual del fabricante (defecto sembrado del Equipo 1) | Usuario `admin` reemplazado por `mant-maipo-sur`; clave de fábrica cambiada en el equipo (simulado) | Secreto `PLC_MANT_PASSWORD` | Desarrollador |

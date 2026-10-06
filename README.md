# Planta Maipo Sur · Taller DevSecOps sobre Infraestructura Crítica

Repositorio del **Equipo 1 · Agua potable** para el Taller DevSecOps sobre Infraestructura Crítica
(Universidad Bernardo O'Higgins). La planta, el PLC y el boletín son **ficticios**, creados para el taller.

- `lector_cloro.py`: servicio que lee el cloro libre desde la pasarela OT y lo muestra al operador.
- `config.yaml`: configuración del lector.
- `plc/controlador.yaml`: configuración del PLC de dosificación.
- `asistente/permisos.yaml`: permisos del asistente de IA del turno.
- `infra/plc.tf`: infraestructura de la pasarela OT declarada como código.
- `.github/workflows/seguridad.yml`: pipeline de seguridad.
- `ENTREGABLE.md`: ficha de blindaje del equipo.

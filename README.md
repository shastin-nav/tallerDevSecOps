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

## Resultado del equipo

- **Ficha de blindaje (entregable):** [`ENTREGABLE.md`](ENTREGABLE.md)
- Fase A · modelo de amenazas: [`docs/modelo-amenazas.md`](docs/modelo-amenazas.md)
- Fase C · propuesta de la IA: [`propuestas/propuesta-7.patch`](propuestas/propuesta-7.patch) (rechazada)
- Guion de exposición: [`docs/guion-90-segundos.md`](docs/guion-90-segundos.md)

## Ejecutarlo

En GitHub: **Actions → seguridad-planta → Run workflow**. Requiere el secreto `PLC_PASSWORD`
(Settings → Secrets and variables → Actions); en el taller cualquier valor sirve.

En local (modo simulación, sin PLC):

```bash
pip install -r requirements.txt
PLC_PASSWORD=demo python lector_cloro.py   # http://127.0.0.1:8080
```

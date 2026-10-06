# Ficha de blindaje

> Taller DevSecOps sobre Infraestructura Crítica · Universidad Bernardo O'Higgins.
> Planta Maipo Sur: escenario **ficticio** creado para el taller. Ningún valor de clave aparece en esta ficha.

## Sistema y equipo
- Sector: **Agua potable** · dosificación de cloro en la planta Maipo Sur (abastece a 80.000 personas). Defecto sembrado: credencial de fábrica en la configuración del controlador.
- Nombre: Equipo 1 · _(nombre del equipo)_
- Roles:
  - Operador de planta (sin teclado, poder de veto): _(nombre)_
  - Desarrollador (con teclado): _(nombre)_
  - Guardián del pipeline (con teclado): _(nombre)_
  - Auditor de IA (sin teclado, lidera la fase C): _(nombre)_
  - Relator (sin teclado, expone los 90 s): _(nombre)_

## Diagrama
- Foto del dibujo de la fase A, sin datos reales: _(subir como `docs/dibujo-fase-a.jpg`)_
- Versión digital del mismo dibujo y amenazas por flecha (STRIDE): [`docs/modelo-amenazas.md`](docs/modelo-amenazas.md)
- Resumen: Operador (HMI) → Lector de cloro en la pasarela OT → PLC-01 → bomba dosificadora → agua. Además: Asistente de IA → PLC, y Repositorio/pipeline → pasarela.

## Tres amenazas
1. **Credencial de fábrica `1111` en el PLC con acceso remoto abierto** / Suplantación + Denegación / Un atacante entra al PLC, cambia la dosis de cloro y deja fuera a los operadores: el agua sale tóxica (sobredosis) o sin desinfectar (falta de cloro) para 80.000 personas, y el turno no puede corregirlo / Control 1: regla Semgrep `credencial-de-fabrica` + Control 3: la pasarela solo puede hablar con la red OT.
2. **Clave del PLC escrita en el repositorio público** / Filtración → Manipulación / Quien lea el repositorio entra a la pasarela y falsea la lectura: el operador ve «NORMAL» mientras el agua sale sin cloro suficiente / Control 1: Gitleaks (job `buscar-secretos`).
3. **Asistente de IA con permiso para escribir en el PLC y sin confirmación humana** / Elevación de privilegios / Un texto inyectado se convierte en una orden real («sube el setpoint al máximo»): riesgo directo para la salud de la población / Control 1: regla Semgrep `asistente-ia-con-escritura-en-plc`.

## Controles
- Enlace a Actions: https://github.com/shastin-nav/tallerDevSecOps/actions/workflows/seguridad.yml
- Controles ejecutados (workflow `seguridad-planta`, [`.github/workflows/seguridad.yml`](.github/workflows/seguridad.yml)):

| Control | Herramienta | Estado actual |
|---|---|---|
| Código propio (`buscar-secretos`) | Gitleaks + Semgrep (`p/python` + [reglas de la planta](.semgrep/reglas-planta.yml)) | ✅ verde |
| Código prestado | Versiones exactas + Trivy fs + OSV-Scanner + SBOM CycloneDX (artefacto `sbom-maipo-sur` → `sbom.cdx.json`) | ✅ verde |
| Configuración | Trivy misconfiguration sobre `infra/` | ✅ verde |
| Prueba funcional | El servicio lee `PLC_PASSWORD` sin imprimirlo | ✅ verde |

- Evidencia, en orden:

| Momento | Resultado | Ejecución |
|---|---|---|
| Ej. 1 · contraseña escrita en `config.yaml` | 🔴 Gitleaks detecta la credencial | [run 37479073218](https://github.com/shastin-nav/tallerDevSecOps/actions/runs/37479073218) |
| Ej. 1 · credencial retirada, se usa `PLC_PASSWORD` | 🟢 Gitleaks y prueba funcional pasan | [run 37480691985](https://github.com/shastin-nav/tallerDevSecOps/actions/runs/37480691985) |
| Fase B · tres controles activos, defecto aún presente | 🔴 fallan los tres controles | [run 37480754518](https://github.com/shastin-nav/tallerDevSecOps/actions/runs/37480754518) |
| Fase B · defecto sembrado y configuración corregidos | 🔴 OSV detecta 2 vulnerabilidades transitivas | [run 37480932486](https://github.com/shastin-nav/tallerDevSecOps/actions/runs/37480932486) · [detalle](https://github.com/shastin-nav/tallerDevSecOps/actions/runs/37481172454) |
| Fase B · dependencias actualizadas | 🟢 todo en verde | [run 37481283596](https://github.com/shastin-nav/tallerDevSecOps/actions/runs/37481283596) |
| Fase C · parche de la IA (PR) | 🔴 Semgrep lo bloquea y el servicio deja de funcionar | [run 37481661298](https://github.com/shastin-nav/tallerDevSecOps/actions/runs/37481661298) |

- Acciones de terceros fijadas a un SHA completo; Trivy (v0.75.0, nunca v0.69.4) y OSV-Scanner descargados en versión exacta con verificación SHA-256. `GITHUB_TOKEN` con permisos mínimos (`contents: read`).
- Modalidad de Gitleaks: **historial completo** (`fetch-depth: 0`). El hallazgo histórico se gestionó por escrito (H1b), sin desactivar reglas.

## Hallazgo y decisión

**Hallazgo principal (defecto sembrado):**
- Hallazgo: credencial de fábrica (usuario `admin`, clave de fábrica del manual) en `plc/controlador.yaml`, con `acceso_remoto: habilitado` para cualquier origen.
- Gravedad: Crítica.
- Decisión y justificación: **Corregir ahora.** Se cambió en el equipo (rotación simulada, [`docs/registro-rotacion.md`](docs/registro-rotacion.md)); la clave nueva vive en el secreto `PLC_MANT_PASSWORD` y el archivo solo guarda el nombre de la variable (`password_env`). El acceso remoto queda limitado a la pasarela OT. Gitleaks no la detectaba porque no parece aleatoria, así que se escribió la regla Semgrep `credencial-de-fabrica`.
- Responsable y fecha: Desarrollador · 06-10-2026.

**Todos los hallazgos gestionados:**

| # | Hallazgo | Detectado por | Gravedad | Decisión | Justificación | Responsable · fecha |
|---|---|---|---|---|---|---|
| H1 | Clave de la pasarela escrita en `config.yaml` | Gitleaks | Crítica | Corregir ahora | Retirada del código; se lee desde el secreto `PLC_PASSWORD`. | Desarrollador · 06-10-2026 |
| H1b | La misma clave sigue en el historial (commit `dc95c45`) | Gitleaks (historial) | Crítica | Aceptar temporalmente con justificación | Se considera comprometida y se rotó (simulado): el valor del historial ya no sirve. Queda registrada en [`.gitleaksignore`](.gitleaksignore) con su explicación; cualquier secreto nuevo sigue bloqueando. Limpiar el historial requiere un procedimiento controlado (ver Pendientes). | Guardián del pipeline · revisar antes del 30-10-2026 |
| H2 | Credencial de fábrica en `plc/controlador.yaml` (defecto sembrado) | Semgrep `credencial-de-fabrica` | Crítica | Corregir ahora | Ver hallazgo principal. | Desarrollador · 06-10-2026 |
| H3 | `acceso_remoto: habilitado` desde cualquier origen | Revisión del equipo (fase A) | Alta | Corregir ahora | Solo la pasarela OT puede hablarle al PLC. | Desarrollador · 06-10-2026 |
| H4 | Asistente de IA con escritura en el PLC, sin confirmación humana y con claves en su contexto | Semgrep `asistente-ia-con-escritura-en-plc` | Alta | Corregir ahora | Mínimo privilegio: solo lectura, contexto sin configuración sensible, confirmación humana obligatoria. | Auditor de IA · 06-10-2026 |
| H5 | Dependencias sin versión fija (`flask`, `requests`, `pyyaml`) | Control 2 (versiones exactas) | Alta | Corregir ahora | Todas fijadas con `==`, incluidas las transitivas. | Desarrollador · 06-10-2026 |
| H6 | `idna 3.11` · CVE-2026-45409 (GHSA-65pc-fj4g-8rjx), moderada; dependencia transitiva que nadie eligió | OSV-Scanner | Media | Corregir ahora | Actualizada a 3.15, versión corregida y compatible. | Desarrollador · 06-10-2026 |
| H7 | `click 8.3.1` · CVE-2026-7246 (PYSEC-2026-2132); dependencia transitiva | OSV-Scanner | Media | Corregir ahora | Actualizada a 8.3.3, versión corregida y compatible. | Desarrollador · 06-10-2026 |
| H8 | AWS-0104 · la pasarela podía salir a todo internet (`0.0.0.0/0`) | Trivy config | Crítica | Corregir ahora | Salida solo hacia la red OT, puertos 443 y 502. | Guardián del pipeline · 06-10-2026 |
| H9 | AWS-0028 · metadatos de instancia sin token (IMDSv1) | Trivy config | Alta | Corregir ahora | `http_tokens = "required"`. | Guardián del pipeline · 06-10-2026 |
| H10 | AWS-0131 · disco sin cifrar | Trivy config | Alta | Corregir ahora | `root_block_device { encrypted = true }`. | Guardián del pipeline · 06-10-2026 |
| H11 | AWS-0099 / AWS-0124 · grupo y reglas de red sin descripción | Trivy config | Baja | Corregir ahora | Descripciones agregadas para auditoría. | Guardián del pipeline · 06-10-2026 |
| H12 | Gitleaks no reconoce campos en español (`clave:`) | Prueba del equipo | Media | Corregir ahora | Regla `clave-en-espanol` en [`.gitleaks.toml`](.gitleaks.toml). | Guardián del pipeline · 06-10-2026 |
| H13 | Modbus/TCP no tiene autenticación ni cifrado | Revisión del equipo | Alta | Aceptar temporalmente con justificación | Limitación del protocolo y del PLC instalado. Se mitiga con segmentación (solo la pasarela llega al puerto 502) y con un límite físico de la bomba al 60 %. | Operador de planta · revisar el 30-11-2026 |
| H14 | La pasarela OT no tiene un certificado emitido por una CA interna de la planta | Revisión del equipo | Media | Postergar con responsable y fecha | Requiere la CA de la planta. Mientras tanto, `verify=False` está prohibido (regla `tls-sin-verificar`). | Guardián del pipeline · 30-11-2026 |

Ninguna regla se desactivó para obtener verde, y ningún archivo se borró para pasar el análisis.

## Parche de IA

Propuesta #7 «arregla la lectura del controlador», autor `asistente-ia`: [Pull Request #1](https://github.com/shastin-nav/tallerDevSecOps/pull/1) (revisado en *Files changed*, **sin merge**).

- Paquete verificado: **No existe.** `plc_helper_utils` (`plc-helper-utils` en PyPI) responde **HTTP 404** en pypi.org; `requests` sí existe (HTTP 200). Evidencia: [verificación automática](https://github.com/shastin-nav/tallerDevSecOps/actions/runs/37481554108) y [la misma verificación sobre el PR](https://github.com/shastin-nav/tallerDevSecOps/actions/runs/37481776670). Es un nombre alucinado: cualquiera podría registrarlo mañana con código malicioso (*slopsquatting*). Además, en la ejecución del PR el servicio deja de funcionar, porque el import falla.
- Tratamiento de entradas: **Inseguro.** Concatena `registro` y `host` dentro de un comando del sistema y lo ejecuta con `subprocess.run(..., shell=True)`. Un registro como `40001; <orden>` ejecuta lo que el atacante quiera en la pasarela que le habla al PLC (inyección de comandos, CWE-78). Semgrep `comando-con-shell-true` lo bloquea.
- Protecciones desactivadas: **Sí.** `verify=False` apaga la validación TLS (CWE-295): cualquiera en el camino puede leer o alterar los datos. Semgrep `tls-sin-verificar` lo bloquea.
- Destino de datos: **No justificado.** `requests.post(TELEMETRIA, ...)` envía la salida del PLC a un destino que nadie pidió y que ni siquiera está definido en el código. Además, la infraestructura corregida (H8) ya no permite salir fuera de la red OT.
- Veredicto y evidencia: **RECHAZADO en su estado actual.** «Funciona y el análisis pasa» solo era cierto con el pipeline original, que tenía únicamente Gitleaks. Con nuestros controles, el PR queda en rojo: Semgrep lo bloquea y la prueba funcional falla ([run 37481661298](https://github.com/shastin-nav/tallerDevSecOps/actions/runs/37481661298)).
- Explicación para el operador. Se pidió a una IA (Claude): «Explica en máximo dos frases, para una persona operadora de planta, por qué este parche es peligroso. Describe la consecuencia sobre el proceso físico y no inventes datos que no estén en el código». Respuesta:
  > «Este cambio deja que cualquiera que escriba un número de registro también le dé órdenes a la computadora que habla con la bomba de cloro, y manda las lecturas a un destino desconocido sin comprobar con quién habla. En la planta, eso podría terminar en una dosis de cloro alterada sin que el turno lo note.»
  - ¿La corrigió el equipo? _(sí / no · qué se cambió)_
- Firma humana del veredicto: _(nombre del auditor de IA)_. La IA redacta; la autorización es humana.

## Pendientes para un sistema real
- Rotar y revocar de verdad las credenciales en la pasarela y en el PLC físico, y revisar sus accesos (en el taller la rotación es simulada).
- Limpiar el historial con un procedimiento controlado (por ejemplo `git filter-repo` coordinado con todo el equipo) una vez rotada la clave, y retirar H1b de `.gitleaksignore`.
- Proteger la rama `main`: los cuatro trabajos del pipeline como obligatorios y revisión humana antes de cualquier merge.
- Firmar los artefactos antes de desplegar (cosign / sigstore), la estación 5 del pipeline.
- Ganchos pre-commit con Gitleaks en el computador de cada integrante (estación 1).
- Probar el asistente de IA contra inyección de instrucciones (garak / promptfoo) y registrar cada acción en una bitácora de auditoría (repudio).
- CA interna para la pasarela (H14) y evaluar Modbus Security o segmentación adicional (H13).
- Política de umbrales por severidad CVSS (sesión 6): bloquear ≥ 9.0, aprobación para 7.0–8.9, registrar < 7.0.

## Reproducción
- Workflow: **Actions → seguridad-planta → Run workflow** (rama `main`). Requiere el secreto `PLC_PASSWORD` con un valor ficticio.
- Comandos equivalentes en local:

```bash
git clone https://github.com/shastin-nav/tallerDevSecOps && cd tallerDevSecOps
gitleaks git . && semgrep scan --config p/python --config .semgrep/ --error
trivy fs --scanners vuln --severity HIGH,CRITICAL --exit-code 1 . && osv-scanner scan source -r . && trivy config --exit-code 1 infra/
pip install -r requirements.txt && PLC_PASSWORD=valor-ficticio python lector_cloro.py   # http://127.0.0.1:8080
```

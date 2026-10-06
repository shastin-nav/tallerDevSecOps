"""Lector de cloro · Planta Maipo Sur.

Escenario ficticio creado para el Taller DevSecOps sobre Infraestructura Crítica (UBO).
Servicio mínimo que lee la concentración de cloro libre desde la pasarela OT del PLC
y la publica en una página para el operador de turno.

Ejecutar en modo simulación (no necesita PLC):
    pip install -r requirements.txt
    python lector_cloro.py        # abre http://127.0.0.1:8080
"""

import logging
import os
import random

import requests
import yaml
from flask import Flask, jsonify, render_template

RUTA_CONFIG = os.environ.get("RUTA_CONFIG", "config.yaml")

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("lector_cloro")

app = Flask(__name__)


def cargar_config(ruta: str = RUTA_CONFIG) -> dict:
    with open(ruta, encoding="utf-8") as archivo:
        return yaml.safe_load(archivo)


def obtener_clave(cfg: dict) -> str:
    """La clave nunca vive en el repositorio: se lee de la variable de entorno indicada
    en config.yaml, que en GitHub Actions se alimenta desde Settings → Secrets."""
    variable = cfg["plc"]["variable_clave"]
    clave = os.environ.get(variable)
    if not clave:
        raise RuntimeError(f"Falta la variable de entorno {variable} con la clave del PLC")
    return clave


def leer_cloro(cfg: dict) -> float:
    """Devuelve la concentración de cloro libre en mg/L."""
    plc = cfg["plc"]
    if os.environ.get("MODO_SIMULACION", "1") == "1":
        return round(random.uniform(0.6, 1.4), 2)

    respuesta = requests.get(
        f"https://{plc['host']}/api/registros/{int(plc['registro_cloro'])}",
        auth=(plc["usuario"], obtener_clave(cfg)),
        timeout=3,
    )
    respuesta.raise_for_status()
    crudo = int(respuesta.json()["valor"])
    return round(crudo * float(plc["escala"]), 2)


def estado(valor: float, limites: dict) -> str:
    if valor < limites["minimo"]:
        return "BAJO: el agua puede no quedar desinfectada"
    if valor > limites["maximo"]:
        return "ALTO: sobredosificación de cloro"
    return "NORMAL"


@app.route("/")
def inicio():
    cfg = cargar_config()
    valor = leer_cloro(cfg)
    return render_template(
        "index.html", valor=valor, estado=estado(valor, cfg["limites_mg_l"]), planta=cfg["planta"]
    )


@app.route("/api/cloro")
def api_cloro():
    cfg = cargar_config()
    valor = leer_cloro(cfg)
    return jsonify(planta=cfg["planta"], cloro_mg_l=valor, estado=estado(valor, cfg["limites_mg_l"]))


if __name__ == "__main__":
    # Solo escucha en la propia máquina: nunca exponer el lector directamente a internet.
    app.run(host=os.environ.get("HOST", "127.0.0.1"), port=int(os.environ.get("PUERTO", "8080")))

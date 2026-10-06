# Guion de 90 segundos · Equipo 1 · Agua potable

Lo expone el relator o alguien que no tocó el teclado. Sin jerga: se habla de agua y de personas.

**1 · «Nuestro sistema controla… y si falla, pasa esto.» (30 s)**
Nuestro sistema controla cuánto cloro se le pone al agua que toman 80.000 personas en Maipo Sur. Si falla, el agua sale tóxica por exceso de cloro o sin desinfectar por falta, y lo peor que encontramos es que cualquiera podía entrar al controlador con la clave que viene de fábrica, «1111», la misma que aparece en el manual.

**2 · «El control que pusimos habría detenido esto.» (30 s)**
Pusimos tres revisiones automáticas que corren cada vez que alguien sube un cambio. Primero las hicimos fallar a propósito *(mostrar la ejecución en rojo)*: detectaron la clave de fábrica, una contraseña olvidada en el código, dependencias sin versión fija y un servidor que podía mandar datos a todo internet. Lo corregimos y ahora pasa en verde *(mostrar la ejecución en verde)*. La contraseña antigua sigue en el historial: no la borramos, la cambiamos, porque una clave que se filtró ya está comprometida.

**3 · «Con el parche de la IA decidimos… porque…» (30 s)**
Rechazamos el parche de la IA. Usaba un paquete que no existe, dejaba que un número escrito por cualquiera se convirtiera en una orden para la computadora de la bomba, apagaba la verificación de seguridad y mandaba las lecturas a un destino que nadie pidió. La IA puede escribir el borrador, pero la firma que autoriza un cambio en la planta es nuestra.

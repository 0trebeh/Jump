# Jump

Juego de plataformas vertical infinito hecho con **Godot 4**, inspirado en *Doodle Jump* y ampliado con mecánicas de combate.

Salta de plataforma en plataforma, esquiva las trampas y llega lo más alto que puedas.

> 🚧 **En desarrollo:** la base del juego ya se puede jugar. El combate es la siguiente fase.

---

## 🎮 Controles

| Acción | Teclas |
|---|---|
| Moverse a la izquierda | `←` o `A` |
| Moverse a la derecha | `→` o `D` |
| Reiniciar (tras Game Over) | `Enter` o `R` |

El personaje salta automáticamente cada vez que cae sobre una plataforma.

## ✨ Características

- **Rebote automático** con movimiento lateral suave.
- **Paso de un lado a otro:** si sales por un lateral de la pantalla, apareces por el contrario.
- **Generación infinita** de plataformas, siempre al alcance del salto.
- **Tipos de plataforma:**
  - 🟩 **Normal:** rebote estándar.
  - 🟦 **Móvil:** se desplaza de lado a lado.
  - 🟫 **Frágil:** se rompe al pisarla y no te impulsa.
  - 🌀 **Muelle:** aparece sobre algunas plataformas normales y da un salto mucho más alto.
- **Dificultad progresiva:** con la altura, las plataformas se separan y aparecen más plataformas móviles y trampas.
- **Puntuación por altura** y **récord guardado** entre partidas.
- **Gráficos dibujados por código**, sin assets externos.

## 🗺️ Hoja de ruta

- [x] Base del juego: salto, plataformas, cámara, puntuación y Game Over
- [ ] Disparo hacia arriba
- [ ] Enemigos con vida y daño por contacto
- [ ] Sistema de vida del jugador
- [ ] Power-ups (escudo, jetpack…)
- [ ] Menú principal y pausa
- [ ] Efectos de sonido y música
- [ ] Sprites y animaciones

## 🚀 Cómo ejecutarlo

1. Instala [Godot 4.7](https://godotengine.org/download) o superior. La versión estándar basta; no hace falta la de .NET.
2. Clona el repositorio:
   ```bash
   git clone https://github.com/<tu-usuario>/Jump.git
   ```
3. Abre Godot, pulsa **Importar** y selecciona el archivo `project.godot`.
4. Pulsa **F5** para jugar.

## 📁 Estructura del proyecto

```
Jump/
├── scenes/
│   ├── main.tscn        # Escena principal: cámara, HUD y contenedor de plataformas
│   ├── player.tscn      # Jugador
│   └── platform.tscn    # Plataforma (normal, móvil o frágil)
├── scripts/
│   ├── main.gd          # Generación de plataformas, cámara, puntuación y Game Over
│   ├── player.gd        # Movimiento, gravedad, rebote y paso de lado a lado
│   └── platform.gd      # Tipos de plataforma, movimiento, rotura y muelles
└── project.godot
```

## ⚙️ Ajustes

Los parámetros del jugador están expuestos en el **Inspector** del nodo `Player`:

| Parámetro | Valor por defecto | Descripción |
|---|---|---|
| `gravity` | `1500` | Aceleración de la caída |
| `jump_velocity` | `-900` | Fuerza del salto (altura máxima ≈ 270 px) |
| `move_speed` | `380` | Velocidad horizontal máxima |
| `acceleration` | `2400` | Rapidez con la que se alcanza esa velocidad |

## 🛠️ Tecnologías

- [Godot Engine 4.7](https://godotengine.org/)
- GDScript

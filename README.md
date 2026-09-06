# 📓 ApuntesU — Home Challenge, Misión 30 (RLS)

## 📌 Premisa

Un grupo de estudiantes quiere una app para subir apuntes de clase y
compartirlos con el monitor de la materia. El monitor necesita ver los
apuntes de todos, pero cada estudiante solo debe ver los suyos. Ahora
mismo la tabla de apuntes está completamente abierta — cualquiera con
sesión ve y edita lo de cualquiera. Tu trabajo es blindarla con RLS,
exactamente como lo hicimos en clase con `AstroLog`, pero esta vez tú
escribes las políticas, no yo.

No hay backend de Express en este proyecto. Todo pasa entre Supabase y
`http/pruebas.http` — igual que en la parte de clase donde probamos
contra la API de Supabase directamente.

---

## 📜 El Contrato (Tickets obligatorios)

- **Ticket 1:** activar RLS en `apuntes` y escribir la política de
  SELECT — cada estudiante ve solo sus propios apuntes.
- **Ticket 2:** política de INSERT — nadie puede subir un apunte a
  nombre de otro usuario.
- **Ticket 3:** política de UPDATE — nadie puede editar un apunte que
  no sea suyo.
- **Bonus:** el monitor de una materia ve todos los apuntes de esa
  materia, no solo los suyos.

Escribes las 4 políticas en `sql/politicas.sql`. Ahí tienes cada ticket
con una pista de qué hace la política — no el código completo. Si te
quedaste con dudas de la sintaxis exacta, revisa tus apuntes de la
teoría de esta semana y lo que hicimos juntos en `AstroLog` — es
literalmente el mismo patrón, con nombres distintos.

---

## 🛠️ Preparación (hazlo antes de tocar ningún ticket)

1. Ve al SQL Editor de **tu propio proyecto de Supabase** (el mismo que
   ya usas para tu proyecto del curso — no hace falta crear uno nuevo).
2. Corre **todo** `sql/schema.sql`, con las secciones de `insert`
   todavía comentadas.
3. Ve a **Authentication > Users** y crea 2 usuarios manualmente:
   - `alumno@apuntesu.dev` — contraseña `Demo1234!`
   - `monitor@apuntesu.dev` — contraseña `Demo1234!`
4. Copia el UUID de cada uno (columna `UID` en la tabla de usuarios).
5. Vuelve a `sql/schema.sql`, descomenta los dos bloques de `insert`,
   reemplaza `UUID_ALUMNO` y `UUID_MONITOR` por los UUIDs reales, y
   corre esos inserts.
6. Ve a **Project Settings > API** y copia:
   - `Project URL` → variable `supabase_url` en `http/pruebas.http`
   - `publishable key` (antes "anon key") → variable
     `supabase_publishable_key` en `http/pruebas.http`
7. En `http/pruebas.http`, corre las 2 peticiones del **Paso 0** (login).
  Las peticiones siguientes toman automáticamente el `access_token` de
  esas respuestas; no hace falta copiar tokens manualmente.

**Nota sobre los tokens:** duran ~1 hora. Si a mitad de la tarea un
request empieza a fallar con `401` y el mensaje
`"Expected 3 parts in JWT; got 1"`, no es que algo se rompió — es que
la variable del token sigue siendo el placeholder de texto, no un JWT
real. Vuelve a correr el login de ese usuario.

---

## ✅ Cómo trabajar cada ticket

El flujo es siempre el mismo, ticket por ticket:

1. Escribe la política en `sql/politicas.sql`.
2. Cópiala y córrela en el SQL Editor de Supabase.
3. Corre la(s) petición(es) correspondiente(s) en `pruebas.http`.
4. Compara el resultado contra lo que dice el comentario de esa
   petición ("debe devolver...", "debe fallar...").
5. Si no coincide, revisa la sección de errores comunes antes de tocar
   la política otra vez — la mayoría de las veces el problema no es la
   lógica de la política, es un dato mal copiado.

No sigas al siguiente ticket hasta que el actual pase su prueba. Cada
uno depende de que el anterior esté bien.

---

## 🧯 Errores comunes (leer ANTES de asumir que algo está roto)

Esta lista sale de errores reales que salieron probando este mismo
proyecto. Si te topas con alguno, no es un caso especial tuyo.

- **`GET` devuelve `[]` después del Ticket 1a, antes de escribir la
  política de SELECT:** es lo esperado. RLS activado sin políticas
  bloquea todo por diseño. Sigue con el Ticket 1b.

- **`401` con `"Expected 3 parts in JWT; got 1"` o
  `"JWT cryptographic operation failed"`:** ejecuta nuevamente el login
  correspondiente del Paso 0 y vuelve a ejecutar la petición protegida.
  Los tokens se generan automáticamente y duran aproximadamente una hora.

- **`400` con `"invalid input syntax for type uuid"`:** dejaste un
  placeholder como `UUID_DE_ALUMNO` sin reemplazar por el UUID real en
  el body de la petición.

- **Una política no hace nada, ni bloquea ni deja pasar, y no da
  ningún error:** revisa el nombre exacto de la columna
  (`autor_id`, no `author_id`) y que estés comparando con `=`, no con
  `-`. Un typo así no lanza error de sintaxis SQL si el resto de la
  línea es válido — simplemente la condición nunca es verdadera.

- **El bonus del monitor no funciona pero los Tickets 1-3 sí:** revisa
  con esta query, corrida en el SQL Editor, que el `rol` en `perfiles`
  sea exactamente `'monitor'` (sin mayúsculas, sin espacios) y que el
  `materia_id` del monitor coincida con el de los apuntes:
  ```sql
  select * from perfiles;
  ```

- **Un `UPDATE` a una fila ajena no da error, solo devuelve `[]`:** es
  el comportamiento correcto. `USING` filtra en silencio, no lanza
  error — el único caso que da error explícito es un `INSERT` o
  `UPDATE` que sí llega a intentarse pero viola `WITH CHECK`.

---

## 🟢 Estado esperado al terminar

- Nadie puede ver, insertar ni editar apuntes de otro estudiante.
- El monitor ve todos los apuntes de su materia.
- Puedes explicar, sin mirar el código, la diferencia entre `USING` y
  `WITH CHECK` con tus propias palabras.

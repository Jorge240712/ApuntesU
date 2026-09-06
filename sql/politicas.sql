-- ============================================
-- ApuntesU — Tus políticas RLS
-- Completa cada ticket en orden. No sigas al siguiente hasta que
-- el anterior pase la prueba correspondiente en pruebas.http.
-- ============================================


-- ── TICKET 1 — Activar el candado + ver solo lo tuyo ──────────
-- 1a. Activa RLS en la tabla apuntes.
--     (una sola línea, el mismo comando que usamos en clase con avistamientos)
alter table apuntes enable row level security;

-- 1b. Política de SELECT: cada estudiante ve SOLO los apuntes donde
--     autor_id sea igual a su propio auth.uid().
--     Pista: la comparación es un USING con auth.uid() y la columna autor_id.
drop policy if exists "Cada estudiante ve solo sus apuntes" on apuntes;
create policy "Cada estudiante ve solo sus apuntes"
on apuntes
for select
using (auth.uid() = autor_id);


-- ── TICKET 2 — Insertar solo a tu propio nombre ───────────────
-- Política de INSERT: valida que el autor_id que llega en la fila nueva
-- sea el mismo auth.uid() del usuario que hace la petición.
-- Pista: para INSERT no existe fila previa que filtrar — ¿cuál de las
-- dos cláusulas (USING / WITH CHECK) tiene sentido usar aquí?
drop policy if exists "Cada usuario inserta solo sus apuntes" on apuntes;
create policy "Cada usuario inserta solo sus apuntes"
on apuntes
for insert
with check (auth.uid() = autor_id);



-- ── TICKET 3 — Editar solo lo tuyo ────────────────────────────
-- Política de UPDATE: necesita las dos cláusulas al mismo tiempo.
-- Una decide si puedes tocar la fila, la otra valida cómo queda
-- después de la edición.
drop policy if exists "Cada usuario edita solo sus apuntes" on apuntes;
create policy "Cada usuario edita solo sus apuntes"
on apuntes
for update
using (auth.uid() = autor_id)
with check (auth.uid() = autor_id);



-- ── BONUS — El monitor ve toda su materia ─────────────────────
-- Política de SELECT adicional (no reemplaces la del Ticket 1b):
-- deja pasar la fila si quien pregunta es monitor de esa materia.
-- Vas a necesitar un exists() consultando la tabla perfiles,
-- comparando el rol y el materia_id contra la fila de apuntes.
drop policy if exists "El monitor ve los apuntes de su materia" on apuntes;
create policy "El monitor ve los apuntes de su materia"
on apuntes
for select
using (
	exists (
		select 1
		from perfiles
		where perfiles.id = auth.uid()
		  and perfiles.rol = 'monitor'
		  and perfiles.materia_id = apuntes.materia_id
	)
);

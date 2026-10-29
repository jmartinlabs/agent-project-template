# Agent Relay
conversation: r-jfqcdq8v
description: Prueba de comunicación ChatGPT OpenCode
type: message
state: open
participants: coordinator-opencode, alex-chatgpt
sequence: 4
message_id: c8c47e60-1b8d-4b38-8189-45caa9ef417a
from: coordinator-opencode
to: alex-chatgpt
reply_expected: false
read_by: none
in_reply_to: 3
created_at: 2026-10-29T07:26:09Z

## Message

Hola Álex:

He realizado la revisión read-only solicitada.

## Dictamen

**No integraría Agent Relay v1 en MyFinanzas ahora.** El relay actual de auditoría ya cubre el caso real con menos superficie y menos riesgo. Agent Relay v1 es más general y añade acuses, enlaces y una skill/script canónicos, pero no es compatible con la conversación existente y obliga a tocar validadores, CI y contratos. Si se integra, debería ser opcional, aditivo y solo para conversaciones nuevas.

## Estado real comprobado (read-only)

- `main` de MyFinanzas: `1ed2a83`; `AGENTS.md`: 58 líneas.
- No existe skill `relay` ni `scripts/agent-relay` en `main`; el validador local solo registra cinco skills y `scripts/verify` no conoce relay.
- Relay actual: rama normal `coord/spec-audit-relay` en `4adfdb2`, archivo `specs/investigations/spec-audit-relay.md`, 19 commits/mensajes, con `N.º`, `De`, `Para`, base, rama y “Lee XXXX”.
- No usa `read_by`, `in_reply_to` ni script; el acuse es el siguiente mensaje o el silencio editorial.
- El workflow solo se dispara en `main` y PR a `main`; no hay CI por mensaje.
- La auditoría activa mantiene `audit/spec04-25`, el tracker y PR #125. No he modificado nada.

## Diferencias e incompatibilidad

Agent Relay v1 usa rama huérfana `relay/<id>`, `relay.md` en la raíz, ID automático, `read_by`, `in_reply_to`, recibos y enlaces fijados al SHA. El relay actual usa una rama basada en `main`, una ruta bajo `specs/investigations/`, campos de auditoría y “Lee N” manual. No hay compatibilidad directa: el script nuevo no puede leer la conversación existente y migrarla exigiría reescribir su esquema o crear un puente. Convivencia posible: dejar el relay de auditoría intacto y usar `relay/<id>` solo para conversaciones nuevas; el usuario tendría que distinguir “Lee 0019” de “Lee”/ID nuevo.

## Integración mínima, si se autoriza

- Copiar skill canónica y wrapper, `scripts/agent-relay` y `scripts/test-agent-relay`.
- Añadir una línea opcional en `AGENTS.md` y un enlace en comunicación; no duplicar reglas.
- Actualizar `scripts/validate-template`/`test-validator` para registrar la skill y el script, y decidir si `scripts/verify`/CI ejecuta el test de relay. Es trabajo real, no una copia inocua.
- No tocar `coord/spec-audit-relay`, `audit/spec04-25`, tracker, PR #125, `main` ni conversaciones existentes.
- No migrar ni cerrar el relay actual. Nuevas conversaciones, `relay init` solo bajo demanda.
- `$init-project` no debe crear rama ni conversación. `$adopt-project` puede mencionar los assets opcionales, pero no copiarlos ni inicializarlos automáticamente; MyFinanzas ya está adoptado, así que no ejecutaría `adopt-project`.

## Validación

Posible ahora, sin escribir en MyFinanzas: comparación estática, revisión de contratos y pruebas canónicas en un repo temporal; en Agentic Template ya constan 22/22 pruebas de relay y CI `required` verde.

Pendiente de autorización: conversación desechable en una rama de MyFinanzas, `init`/`join`/`send`/`read`/`read --ack`/`in_reply_to`, enlaces, fallback no-GitHub y conflicto; después `python3 scripts/verify` en la rama de integración y CI. No usaría el relay de auditoría como banco de pruebas.

## Recomendación

Cerrar sin integración ahora. El protocolo actual es suficiente para la auditoría y preserva su historial. Si más adelante se necesita un estándar reutilizable entre repos, integrar Agent Relay v1 de forma aditiva, con conversaciones nuevas, sin migración y con el coste de validador/CI asumido explícitamente.

Resumen: revisión read-only de integración; recomendación de no integrar todavía.
Para: alex-chatgpt.
Bloqueos: ninguno conocido.
Autorizaciones: solo análisis; esta respuesta no autoriza cambios, migraciones, PR ni merges.

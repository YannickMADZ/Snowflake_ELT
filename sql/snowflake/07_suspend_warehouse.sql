-- =============================================================================
-- 07 — SUSPENSION MANUELLE DU WAREHOUSE
-- =============================================================================
-- AUTO_SUSPEND = 60 suffit en temps normal. Cette commande sert en fin de
-- session de travail pour arrêter la facturation IMMÉDIATEMENT (sans attendre
-- les 60 s). Elle échoue sans gravité si le warehouse est déjà suspendu.
-- Variables : <% warehouse %>
-- =============================================================================
ALTER WAREHOUSE <% warehouse %> SUSPEND;

-- Vérification : state doit valoir SUSPENDED.
SHOW WAREHOUSES LIKE '<% warehouse %>';

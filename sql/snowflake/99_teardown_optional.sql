-- =============================================================================
-- 99 — (OPTIONNEL) SUPPRESSION COMPLÈTE DE L'ENVIRONNEMENT
-- =============================================================================
-- Supprime database (donc schemas, stage, tables) et warehouse. À utiliser à
-- la fin du projet pour ne plus payer de stockage. Irréversible au-delà du
-- Time Travel (1 jour).
-- Variables : <% database %>, <% warehouse %>
-- =============================================================================
DROP DATABASE IF EXISTS <% database %>;
DROP WAREHOUSE IF EXISTS <% warehouse %>;

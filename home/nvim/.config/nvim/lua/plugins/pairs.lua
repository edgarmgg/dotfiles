-- mini.pairs sigue cerrando ( [ { " solo, pero sin bloquearme: por defecto no
-- cierra si al lado hay una letra o comilla, ni dentro de strings, ni si los
-- cierres quedan desbalanceados. Aquí lo quito para poder poner un corchete
-- donde quiera.
return {
  {
    "nvim-mini/mini.pairs",
    opts = {
      -- Patrón que nunca coincide: siempre cierra, haya lo que haya al lado.
      skip_next = "[^%s%S]",
      skip_ts = {},
      skip_unbalanced = false,
    },
  },
}

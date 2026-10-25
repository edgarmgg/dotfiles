/*
 * Universidad de La Laguna
 * Escuela Superior de Ingeniería y Tecnología
 * Grado en Ingeniería Informática
 * Informática Básica 2026-2027
 *
 * @file %FILE%
 * @author Edgar Manuel Gómez García
 * @date %DATE%
 * @brief
 * @bug There are no known bugs
 */

#include "%BASE%.h"

int main(int argc, char* argv[]) {
  PrintProgramPurpose();
  constexpr int kCorrectNumber{2};
  if (!CheckCorrectParameters(argc, argv, kCorrectNumber)) {
    return 1;
  }
  return 0;
}

#!/bin/bash

# Script per eseguire comandi make in sequenza

echo "Compilazione nella directory ~/Desktop/UninaSoC_plic/sw"
if make -C ~/Desktop/UninaSoC_PLIC/sw/SoC/examples/plic_test/; then
    echo "Compilazione completata con successo."
else
    echo "Errore durante la compilazione nella directory ~/Desktop/UninaSoC_plic/sw."
    exit 1
fi

echo "Esecuzione: make program_bitstream"
if make program_bitstream; then
    echo "Comando make program_bitstream completato con successo."
else
    echo "Errore durante l'esecuzione di make program_bitstream."
    exit 1
fi

echo "Esecuzione: make load_binary"
if make load_binary; then
    echo "Comando make load_binary completato con successo."
else
    echo "Errore durante l'esecuzione di make load_binary."
    exit 1
fi

echo "Esecuzione: make open_ila"
if make open_ila; then
    echo "Comando make open_ila completato con successo."
else
    echo "Errore durante l'esecuzione di make open_ila."
    exit 1
fi

echo "Tutti i comandi sono stati eseguiti con successo!"

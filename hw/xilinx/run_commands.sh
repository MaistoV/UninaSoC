#!/bin/bash

# Script per eseguire comandi make in sequenza

echo "Compilazione nella directory ~/Desktop/UninaSoC_plic/sw"
if make -C /home/stefano/Desktop/Work/Projects/vesuvius/b_plic/sw/SoC/examples/interrupts/; then
    echo "Compilazione completata con successo."
else
    echo "Errore durante la compilazione."
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

echo "Esecuzione: make vio_reset"
if make vio_reset; then
    echo "Comando make vio_reset completato con successo."
else
    echo "Errore durante l'esecuzione di make vio_reset."
    exit 1
fi

echo "Tutti i comandi sono stati eseguiti con successo!"

import numpy as np


def generarNumeros(n: int = 10000, media: float = 0, desv: float = 1) -> np.array:
    """Genera un Array de Numpy de números pseudo aleatorios 
    con distribución normal. 

    Args:
        n (int): Tamaño del array
        media (float): Media de la distribución
        desv (float): Desviación estándar de la distribución

    Returns:
        np.array: Array con los números normales
    """
    x = np.random.normal(loc=media, scale=desv, size=n)
    return x


def escribirArchivo(nombre: str, numeros: np.array):
    """Escribe un array en un archivo de texto, si los números son negativos
    entonces escribe un cero.

    Args:
        nombre (str): nombre (ruta) del archivo a escribir
        numeros (np.array): array con los números normales
    """
    with open(nombre, 'w') as f:
        for num in numeros:
            if num < 0:
                num = 0
            f.write(str(num)+'\n')
        f.close()


if __name__ == '__main__':
    # Funcionalidad principal
    escribirArchivo('normal.txt', generarNumeros(100, 100, 24))

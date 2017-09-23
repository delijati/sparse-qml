import numpy
import matplotlib.pyplot as plt

IMGPATH = "images/sparse-qml.png"


def main():
    """
    Plot the sparsity pattern of arrays
    """
    # set image size
    plt.figure(figsize=(2.56, 2.56))
    x = numpy.random.randn(20, 20)
    x[5] = 0.
    x[:, 12] = 0.

    plt.spy(x, precision=0.1, markersize=5)

    plt.savefig(IMGPATH)


if __name__ == "__main__":
    main()

class List2D<E> {

  List<E> list = [];

  int width;
  int height;

  int get length => list.length;

  List2D(int width, int height)
  {
    this.width = width;
    this.height = height;
    list = new List<E>(width * height);
    fill(null);
  }

  E get(int x, int y)
  {
    return list[index(x, y)];
  }

  set(int x, int y, E object)
  {
    list[index(x, y)] = object;
  }

  int index(int x, int y)
  {
    return x + width * y;
  }

  int xCoord(int index) {
    return (index % width).floor();
  }

  int yCoord(int index) {
    return (index / width).floor();
  }

  int getWidth()
  {
    return width;
  }

  int getHeight()
  {
    return height;
  }

  void fill(E object)
  {
    for (int i = 0; i < list.length; i++)
    {
      list[i] = object;
    }
  }

  int indexOf(object) {
    for(int i = 0; i < length; i++) {
      if(list[i] == object)
        return i;
    }
    return -1;
  }

}


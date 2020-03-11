# ----------------------------------------
# OpenGL compilation with g++
# ----------------------------------------

rungl() {
    FILENAME=${$(basename -- "$@")%.*}
    g++ -std=c++11 -c "$FILENAME.cpp"
    g++ "$FILENAME.o" -o "$FILENAME" -lGL -lGLU -lglfw3 -lX11 -lXxf86vm -lXrandr -lpthread -lXi -ldl -lXinerama -lXcursor
}

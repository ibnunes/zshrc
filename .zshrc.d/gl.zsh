# ----------------------------------------
# OpenGL compilation with g++
# ----------------------------------------

rungl() {
    FILENAME=${$(basename -- "$@")%.*}
    if [ ! -z $(type 'runcpp' | grep 'function') ]; then
        runcpp -c "$FILENAME.cpp"
        runcpp "$FILENAME.o" -o "$FILENAME" -lGL -lGLU -lglfw3 -lX11 -lXxf86vm -lXrandr -lpthread -lXi -ldl -lXinerama -lXcursor
    else
        g++ -std=c++11 -c "$FILENAME.cpp"
        g++ "$FILENAME.o" -o "$FILENAME" -lGL -lGLU -lglfw3 -lX11 -lXxf86vm -lXrandr -lpthread -lXi -ldl -lXinerama -lXcursor
    fi
}

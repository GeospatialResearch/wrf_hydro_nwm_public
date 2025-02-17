FROM ubuntu AS build
# Create build layer to compile the software

WORKDIR /wrf_hydro

# Install dependencies for compilation
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bzip2 \
        ca-certificates \
        cmake \
        g++ \
        gfortran \
        git \
        libnetcdf-dev \
        libnetcdff-dev \
        libopenmpi-dev \
        libswitch-perl \
        m4 \
        make \
        mpi-default-dev \
        netcdf-bin \
        tcsh \
        wget && \
    rm -fr /var/lib/apt/lists/*


# Copy files required for compilation into image
COPY src/ src/
COPY tests/ tests/
COPY CMakeLists.txt .

WORKDIR /wrf_hydro/build

# Compile WRF-Hydro
RUN cmake .. && \
    make -j 4

# Initialise test data
RUN make croton

WORKDIR /wrf_hydro/build/Run

FROM ubuntu AS run

# Create minimised run image

WORKDIR /app

# Install runtime dependencies
# Dependencies which are unclear if they are runtime or compilation time are added
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libnetcdff-dev \
        libnetcdf-dev\
        libopenmpi-dev \
        netcdf-bin \
        mpi-default-dev && \
    rm -fr /var/lib/apt/lists/*

# Copy compiled executable and test data from build image
COPY --from=build /wrf_hydro/build/Run /app

CMD ./wrf_hydro.exe

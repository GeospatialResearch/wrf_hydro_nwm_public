FROM ubuntu
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

# Make safe output folder that won't be overwritten by existing files
RUN mkdir docker_volume

WORKDIR /wrf_hydro/build/Run

# Prepare docker volume for wrf_hydro run by clearing it, ignoring if it is empty
CMD rm -r docker_volume/* 2> /dev/null || true && \
    # Run wrf_hydro
    ./wrf_hydro.exe && \
    # Copy input and output files to docker_volume for easy/safe retrieval
    cp -r ./* ../docker_volume

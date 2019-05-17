ARG base_image

FROM $base_image

WORKDIR /go/src/github.com/microsoft/cobalt/

ARG build_directory
RUN echo "INFO: copying $build_directory"
# Copy the recently modified terraform templates
ADD $build_directory *.go ./
# Run a fresh clean/format/test run
CMD ["go", "run", "magefile.go"]
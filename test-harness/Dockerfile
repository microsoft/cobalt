ARG base_img_tag

FROM msftcse/cobalt-test-base:$base_img_tag
WORKDIR /go/src/app

ARG build_directory
RUN echo "INFO: copying $build_directory"
# Copy the recently modified terraform templates
ADD $build_directory *.go ./

# Update the dependency artifacts
RUN ["dep", "ensure", "-v"]

# Run a fresh clean/format/test run
CMD ["go", "run", "magefile.go"]
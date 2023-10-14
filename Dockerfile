FROM node:16-slim AS builder
WORKDIR /baasappstoregateway
COPY package.json .
RUN npm i

# Create a new stage for the production image
FROM node:16-slim
WORKDIR /baasappstoregateway

# Copy only necessary files from the builder stage
COPY --from=builder /baasappstoregateway/node_modules ./node_modules
COPY . .

EXPOSE 4001
CMD npm start

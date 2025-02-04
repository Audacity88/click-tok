#!/bin/bash

echo "Updating attributes to required..."

# Function to wait for attribute deletion
wait_for_deletion() {
    sleep 2
}

# Videos collection
echo "Updating videos collection attributes..."

# String attributes
for key in "title" "caption" "authorId" "author" "videoFileId" "thumbnailFileId"; do
    size=256
    if [ "$key" = "caption" ]; then
        size=1000
    elif [ "$key" = "authorId" ] || [ "$key" = "videoFileId" ] || [ "$key" = "thumbnailFileId" ]; then
        size=255
    fi
    
    echo "Processing $key..."
    appwrite databases delete-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "$key"
    wait_for_deletion
    appwrite databases create-string-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "$key" --size $size --required true
done

# Integer attributes
for key in "likes" "comments" "shares"; do
    echo "Processing $key..."
    appwrite databases delete-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "$key"
    wait_for_deletion
    appwrite databases create-integer-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "$key" --required true --min 0 --max 2147483647
done

# Float attribute
echo "Processing videos createdAt..."
appwrite databases delete-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "createdAt"
wait_for_deletion
appwrite databases create-float-attribute --database-id "67a247c300211b53cde4" --collection-id "videos" --key "createdAt" --required true

# Likes collection
echo "Updating likes collection attributes..."

# String attributes
for key in "userId" "videoId"; do
    echo "Processing $key..."
    appwrite databases delete-attribute --database-id "67a247c300211b53cde4" --collection-id "likes" --key "$key"
    wait_for_deletion
    appwrite databases create-string-attribute --database-id "67a247c300211b53cde4" --collection-id "likes" --key "$key" --size 255 --required true
done

# Float attribute
echo "Processing likes createdAt..."
appwrite databases delete-attribute --database-id "67a247c300211b53cde4" --collection-id "likes" --key "createdAt"
wait_for_deletion
appwrite databases create-float-attribute --database-id "67a247c300211b53cde4" --collection-id "likes" --key "createdAt" --required true

# Comments collection
echo "Updating comments collection attributes..."

# String attributes
for key in "userId" "videoId"; do
    echo "Processing $key..."
    appwrite databases delete-attribute --database-id "67a247c300211b53cde4" --collection-id "comments" --key "$key"
    wait_for_deletion
    appwrite databases create-string-attribute --database-id "67a247c300211b53cde4" --collection-id "comments" --key "$key" --size 255 --required true
done

echo "Processing text..."
appwrite databases delete-attribute --database-id "67a247c300211b53cde4" --collection-id "comments" --key "text"
wait_for_deletion
appwrite databases create-string-attribute --database-id "67a247c300211b53cde4" --collection-id "comments" --key "text" --size 1000 --required true

# Float attribute
echo "Processing comments createdAt..."
appwrite databases delete-attribute --database-id "67a247c300211b53cde4" --collection-id "comments" --key "createdAt"
wait_for_deletion
appwrite databases create-float-attribute --database-id "67a247c300211b53cde4" --collection-id "comments" --key "createdAt" --required true

# Users collection
echo "Updating users collection attributes..."

# String attributes
for key in "username" "name"; do
    echo "Processing $key..."
    appwrite databases delete-attribute --database-id "67a247c300211b53cde4" --collection-id "users" --key "$key"
    wait_for_deletion
    appwrite databases create-string-attribute --database-id "67a247c300211b53cde4" --collection-id "users" --key "$key" --size 256 --required true
done

# Integer attributes
for key in "followersCount" "followingCount" "videosCount"; do
    echo "Processing $key..."
    appwrite databases delete-attribute --database-id "67a247c300211b53cde4" --collection-id "users" --key "$key"
    wait_for_deletion
    appwrite databases create-integer-attribute --database-id "67a247c300211b53cde4" --collection-id "users" --key "$key" --required true --min 0 --max 2147483647
done

# Float attribute
echo "Processing users createdAt..."
appwrite databases delete-attribute --database-id "67a247c300211b53cde4" --collection-id "users" --key "createdAt"
wait_for_deletion
appwrite databases create-float-attribute --database-id "67a247c300211b53cde4" --collection-id "users" --key "createdAt" --required true

echo "All attributes updated successfully!" 
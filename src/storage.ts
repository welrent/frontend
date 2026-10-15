import {
  CreateBucketCommand,
  GetObjectCommand,
  HeadBucketCommand,
  PutObjectCommand,
  S3Client,
} from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

import { required } from "./env.js";

export const uploadBucket = "uploads";

export const s3 = new S3Client({
  region: required("AWS_REGION"),
  endpoint: required("AWS_ENDPOINT_URL_S3"),
  forcePathStyle: true,
  credentials: {
    accessKeyId: required("AWS_ACCESS_KEY_ID"),
    secretAccessKey: required("AWS_SECRET_ACCESS_KEY"),
  },
});

export async function ensureBucket(): Promise<void> {
  try {
    await s3.send(new HeadBucketCommand({ Bucket: uploadBucket }));
  } catch {
    await s3.send(new CreateBucketCommand({ Bucket: uploadBucket }));
  }
}

export async function putText(key: string, body: string): Promise<void> {
  await ensureBucket();
  await s3.send(
    new PutObjectCommand({
      Bucket: uploadBucket,
      Key: key,
      Body: body,
      ContentType: "text/plain",
    }),
  );
}

export async function getText(key: string): Promise<string> {
  const response = await s3.send(
    new GetObjectCommand({ Bucket: uploadBucket, Key: key }),
  );
  return (await response.Body?.transformToString()) ?? "";
}

export async function signedGet(key: string): Promise<string> {
  return getSignedUrl(
    s3,
    new GetObjectCommand({ Bucket: uploadBucket, Key: key }),
    { expiresIn: 3600 },
  );
}

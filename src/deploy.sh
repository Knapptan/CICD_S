#!/bin/bash

REMOTE_HOST=""
REMOTE_USER=""
REMOTE_DIR=""

scp -o StrictHostKeyChecking=no src/cat/s21_cat src/grep/s21_grep $REMOTE_USER@$REMOTE_HOST:/tmp/

if [ $? -ne 0 ]; then
  echo "Ошибка при копировании файлов"
  exit 1
fi

ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST "mv /tmp/s21_cat $REMOTE_DIR; mv /tmp/s21_grep $REMOTE_DIR"

if [ $? -ne 0 ]; then
  echo "Ошибка при перемещении файлов"
  exit 1
fi

echo "Файлы успешно скопированы"

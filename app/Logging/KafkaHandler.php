<?php

namespace App\Logging;

use Illuminate\Support\Facades\Log;
use Junges\Kafka\Facades\Kafka;
use Junges\Kafka\Message\Message;
use Monolog\Handler\AbstractProcessingHandler;
use Monolog\LogRecord;
use Throwable;

class KafkaHandler extends AbstractProcessingHandler
{
    protected function write(LogRecord $record): void
    {
        try {
            Kafka::publish()
                ->onTopic('app-logs')
                ->withMessage(new Message(
                    body: [
                        'app' => config('app.name'),
                        'channel' => $record->channel,
                        'level' => strtolower($record->level->getName()),
                        'message' => $record->message,
                        'context' => $record->context,
                        'datetime' => $record->datetime->format('c'),
                    ]
                ))
                ->send();
        } catch (Throwable $e) {
            // Kafka 不可用時不應讓 request 失敗，改寫回預設檔案 log
            Log::channel('single')->warning('Kafka log publish failed: '.$e->getMessage());
        }
    }
}

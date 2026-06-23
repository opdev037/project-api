<?php

namespace App\Logging;

use Monolog\Logger;

class CreateKafkaLogger
{
    public function __invoke(array $config): Logger
    {
        $logger = new Logger('kafka');
        $logger->pushHandler(new KafkaHandler());

        return $logger;
    }
}

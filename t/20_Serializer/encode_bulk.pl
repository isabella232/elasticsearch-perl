# Licensed to Elasticsearch B.V. under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. Elasticsearch B.V. licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

use Test::More;
use Test::Deep;
use Test::Exception;
use Search::Elasticsearch;

our $JSON_BACKEND;
my $utf8_bytes = "彈性搜索";
my $utf8_str   = $utf8_bytes;
utf8::decode($utf8_str);
my $hash = { "foo" => "$utf8_str" };
my $arr       = [ $hash, $hash ];
my $json_hash = qq({"foo":"$utf8_bytes"});
my $json_arr  = qq($json_hash\n$json_hash\n);

isa_ok my $s
    = Search::Elasticsearch->new( serializer => $JSON_BACKEND )
    ->transport->serializer,
    "Search::Elasticsearch::Serializer::$JSON_BACKEND", 'Serializer';

is $s->encode_bulk(), undef,    #
    'Enc - No args returns undef';
is $s->encode_bulk(undef), undef,    #
    'Enc - Undef returns undef';
is $s->encode_bulk(''), '',          #
    'Enc - Empty string returns same';
is $s->encode_bulk('foo'), 'foo',    #
    'Enc - String returns same';
is $s->encode_bulk($utf8_str), $utf8_bytes,    #
    'Enc - Unicode string returns encoded';
is $s->encode_bulk($utf8_bytes), $utf8_bytes,    #
    'Enc - Unicode bytes returns same';
is $s->encode_bulk($arr), $json_arr,             #
    'Enc - Array returns JSON';
is $s->encode_bulk( [ $json_hash, $json_hash ] ), $json_arr,    #
    'Enc - Array of strings';
throws_ok { $s->encode_bulk($hash) } qr/must be an array/,      #
    'Enc - Hash dies';
throws_ok { $s->encode_bulk( \$utf8_str ) } qr/Serializer/,     #
    'Enc - scalar ref dies';
throws_ok { $s->encode_bulk( [ \$utf8_str ] ) } qr/Serializer/,    #
    'Enc - array of scalar ref dies';

done_testing;

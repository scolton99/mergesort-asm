import fs   from 'fs/promises';

const DEFAULT_ARRAY_SIZE   = 106_490;
const DEFAULT_ELEMENT_SIZE = 'byte';

const SIZE_MAP = {
  byte: 8,
  word: 16,
  long: 32
};

const STR_SIZE_MAP = {
  byte: 4,
  word: 6,
  long: 11
};

const element_bits  = sz => SIZE_MAP[sz];
const bit_to_byte   = byte => byte >> 3;
const element_bytes = sz => bit_to_byte(element_bits(sz));
const array_bytes   = (asz, esz) => asz * element_bytes(esz);

const spaces  = num => {
  let ret = "";
  for (let i = 0; i < num; ++i)
    ret += " ";
  return ret;
}

const INDENT = spaces(12);

const HEADER =
`${INDENT};; Generated by gen_rand.mjs
${INDENT}.cdecls C,LIST,"msp430.h"
${INDENT}.global INPUT_ARR,OUTPUT_ARR,ARR_SIZE,EL_SIZE

${INDENT}.data`;

const display = (num, esz) => (spaces(STR_SIZE_MAP[esz]) + num).slice(-1 * STR_SIZE_MAP[esz]);

const main = async () => {
  let ARRAY_SIZE   = parseInt(process.argv[2]);
  let ELEMENT_SIZE = process.argv[3];

  if (isNaN(ARRAY_SIZE)) {
    console.warn(`Specified array size ${process.argv[2]} could not be parsed; using default of ${DEFAULT_ARRAY_SIZE} elements`);
    ARRAY_SIZE = DEFAULT_ARRAY_SIZE;
  }

  if (!(ELEMENT_SIZE in SIZE_MAP)) {
    console.warn(`Specified element size ${ELEMENT_SIZE} invalid, using default of ${DEFAULT_ELEMENT_SIZE}.`);
    ELEMENT_SIZE = DEFAULT_ELEMENT_SIZE;
  }

  const numbers = [];

  for (let i = 0; i < ARRAY_SIZE; ++i)
    numbers.push(Math.floor(Math.random() * Math.pow(2, SIZE_MAP[ELEMENT_SIZE])));

  const sections = [];

  for (let i = 0; i < ARRAY_SIZE; i += 100) {
    const section = numbers.slice(i, i + 100);
    const formatted_section = section.map(it => display(it, ELEMENT_SIZE));

    sections.push(formatted_section);
  }

  const data_output = sections.join(`\n${INDENT}.${ELEMENT_SIZE}  `);

  const arr_size     = `ARR_SIZE    .field  ${ARRAY_SIZE}, 20`;
  const el_size      = `EL_SIZE     .byte   ${element_bits(ELEMENT_SIZE)}\t\t`;
  const input_array  = `INPUT_ARR   .${ELEMENT_SIZE}  ${data_output}`;
  const output_array = `OUTPUT_ARR  .space  ${array_bytes(ARRAY_SIZE, ELEMENT_SIZE)}`;

  const output = `${HEADER}\n${arr_size}\n${el_size}\n\n${input_array}\n\n${output_array}`;
  
  await fs.writeFile('data.asm', output);
};

main();